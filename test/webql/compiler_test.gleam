import webql/compiler
import webql/compiler/diagnostic
import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/resolver/reference
import webql/compiler/source

pub fn compile_resolves_module_test() {
  let source = "-> out: Int {}"
  let compiler = compiler.new() |> compiler.add_typename("Int")

  let assert Ok(module) = compiler.compile(compiler, source)

  assert module
    == ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 8, end: 11),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 14),
    )
}

pub fn compile_materializes_node_binding_ports_from_singular_adders_test() {
  let source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let compiler =
    compiler.new()
    |> compiler.add_typenames(["Int"])
    |> compiler.add_nodes(["Math"])
    |> compiler.add_input("Math", #("r", "Int"))
    |> compiler.add_input("Math", #("l", "Int"))
    |> compiler.add_output("Math", #("value", "Int"))

  let assert Ok(ast.Module(operation:, ..)) = compiler.compile(compiler, source)

  let assert [
    ast.Edge(
      from: ast.PortOutput(path: ["in"], reference: reference.Output(0), ..),
      to: ast.PortInput(path: ["m", "l"], reference: reference.Input(2), ..),
      reference: reference.Edge(0),
      ..,
    ),
    ast.Edge(
      from: ast.PrimitiveOutput(typename: reference.Typename(0), ..),
      to: ast.PortInput(path: ["m", "r"], reference: reference.Input(1), ..),
      reference: reference.Edge(1),
      ..,
    ),
    ast.Edge(
      from: ast.PortOutput(
        path: ["m", "value"],
        reference: reference.Output(1),
        ..,
      ),
      to: ast.PortInput(path: ["out"], reference: reference.Input(0), ..),
      reference: reference.Edge(2),
      ..,
    ),
  ] = operation.edges
}

pub fn compile_materializes_node_binding_ports_test() {
  let source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let compiler =
    compiler.new()
    |> compiler.add_typename("Int")
    |> compiler.add_node("Math")
    |> compiler.add_inputs("Math", [#("r", "Int"), #("l", "Int")])
    |> compiler.add_outputs("Math", [#("value", "Int")])

  let assert Ok(ast.Module(operation:, ..)) = compiler.compile(compiler, source)

  let assert [
    ast.Binding(
      name: "m",
      value: ast.NodeValue(name: "Math", reference: reference.Node(0), ..),
      reference: reference.Binding(0),
      ..,
    ),
  ] = operation.bindings

  let assert [
    ast.Edge(
      from: ast.PortOutput(path: ["in"], reference: reference.Output(0), ..),
      to: ast.PortInput(path: ["m", "l"], reference: reference.Input(2), ..),
      reference: reference.Edge(0),
      ..,
    ),
    ast.Edge(
      from: ast.PrimitiveOutput(typename: reference.Typename(0), ..),
      to: ast.PortInput(path: ["m", "r"], reference: reference.Input(1), ..),
      reference: reference.Edge(1),
      ..,
    ),
    ast.Edge(
      from: ast.PortOutput(
        path: ["m", "value"],
        reference: reference.Output(1),
        ..,
      ),
      to: ast.PortInput(path: ["out"], reference: reference.Input(0), ..),
      reference: reference.Edge(2),
      ..,
    ),
  ] = operation.edges
}

pub fn compile_ignores_unknown_node_port_registration_test() {
  let source = "in: Int -> out: Int { m = Math .in -> m.l m.value -> .out }"

  let compiler =
    compiler.new()
    |> compiler.add_typename("Int")
    |> compiler.add_node("Math")
    |> compiler.add_inputs("Nope", [#("l", "Int")])
    |> compiler.add_outputs("Nope", [#("value", "Int")])

  let assert Error(error) = compiler.compile(compiler, source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownInput([
        "m",
        "l",
      ])),
      span: source.Span(start: 38, end: 41),
    )
}

pub fn compile_missing_port_typename_falls_back_to_next_reference_test() {
  let source = "-> out: Int { m = Math m.value -> .out }"

  let compiler =
    compiler.new()
    |> compiler.add_typename("Int")
    |> compiler.add_node("Math")
    |> compiler.add_output("Math", #("value", "String"))

  let assert Ok(ast.Module(operation:, ..)) = compiler.compile(compiler, source)

  let assert [
    ast.Edge(
      from: ast.PortOutput(
        path: ["m", "value"],
        reference: reference.Output(0),
        ..,
      ),
      to: ast.PortInput(path: ["out"], reference: reference.Input(0), ..),
      reference: reference.Edge(0),
      ..,
    ),
  ] = operation.edges
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let compiler = compiler.new()
  let assert Error(error) = compiler.compile(compiler, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let compiler = compiler.new()
  let assert Error(error) = compiler.compile(compiler, "{")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ParserDiagnostic(parser_diagnostic.UnexpectedToken(
        token.LBrace,
      )),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_resolver_diagnostic_test() {
  let source = "-> out: Int {}"
  let compiler = compiler.new()

  let assert Error(error) = compiler.compile(compiler, source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownTypename(
        "Int",
      )),
      span: source.Span(start: 8, end: 11),
    )
}
