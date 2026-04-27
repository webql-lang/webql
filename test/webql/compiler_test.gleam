import webql/compiler
import webql/compiler/diagnostic
import webql/compiler/ir
import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/reference
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/source
import webql/compiler/typechecker/diagnostic as typechecker_diagnostic
import webql/loader/schema

pub fn compile_resolves_module_test() {
  let operation_source = "-> out: Int {}"

  let schema = schema.add_typename(schema.new(), "Int")
  let compiler = compiler.new(schema)

  let assert Ok(module) = compiler.compile(compiler, operation_source)

  assert module
    == ir.Module(
      operation: ir.Operation(
        inputs: [],
        outputs: [ir.Return(name: "out", typename: "Int")],
        nodes: [],
        edges: [],
      ),
    )
}

pub fn compile_materializes_node_binding_ports_from_singular_adders_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let compiler =
    compiler.new(
      schema.new()
      |> schema.add_typename("Int")
      |> schema.add_node("Math")
      |> schema.add_inputs(reference.Node(0), [
        #("r", reference.Typename(0)),
        #("l", reference.Typename(0)),
      ])
      |> schema.add_outputs(reference.Node(0), [
        #("value", reference.Typename(0)),
      ]),
    )

  let assert Ok(ir.Module(operation:)) =
    compiler.compile(compiler, operation_source)

  let assert [
    ir.Edge(from: ir.Output(path: ["in"]), to: ir.Input(path: ["m", "l"])),
    ir.Edge(
      from: ir.PrimitiveOutput(value: ir.IntPrimitive(1)),
      to: ir.Input(path: ["m", "r"]),
    ),
    ir.Edge(from: ir.Output(path: ["m", "value"]), to: ir.Input(path: ["out"])),
  ] = operation.edges
}

pub fn compile_materializes_node_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let compiler =
    compiler.new(
      schema.new()
      |> schema.add_typename("Int")
      |> schema.add_node("Math")
      |> schema.add_inputs(reference.Node(0), [
        #("r", reference.Typename(0)),
        #("l", reference.Typename(0)),
      ])
      |> schema.add_outputs(reference.Node(0), [
        #("value", reference.Typename(0)),
      ]),
    )

  let assert Ok(ir.Module(operation:)) =
    compiler.compile(compiler, operation_source)

  let assert [ir.ExternalNode(name: "m", node: "Math")] = operation.nodes

  let assert [
    ir.Edge(from: ir.Output(path: ["in"]), to: ir.Input(path: ["m", "l"])),
    ir.Edge(
      from: ir.PrimitiveOutput(value: ir.IntPrimitive(1)),
      to: ir.Input(path: ["m", "r"]),
    ),
    ir.Edge(from: ir.Output(path: ["m", "value"]), to: ir.Input(path: ["out"])),
  ] = operation.edges
}

pub fn compile_materializes_definition_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { SubOperation = in: String -> out: Int { ti = ToInt .in -> ti.value ti.value -> .out } m = Math so = SubOperation \"123\" -> so.in so.out -> m.l .in -> m.r m.value -> .out }"

  let compiler =
    compiler.new(
      schema.new()
      |> schema.add_typenames(["Int", "String"])
      |> schema.add_node("ToInt")
      |> schema.add_inputs(reference.Node(0), [
        #("value", reference.Typename(1)),
      ])
      |> schema.add_outputs(reference.Node(0), [
        #("value", reference.Typename(0)),
      ])
      |> schema.add_node("Math")
      |> schema.add_inputs(reference.Node(1), [
        #("l", reference.Typename(0)),
        #("r", reference.Typename(0)),
      ])
      |> schema.add_outputs(reference.Node(1), [
        #("value", reference.Typename(0)),
      ]),
    )

  let assert Ok(ir.Module(operation:)) =
    compiler.compile(compiler, operation_source)

  let assert [
    ir.ExternalNode(name: "m", node: "Math"),
    ir.InlineNode(name: "so", operation: sub_operation),
  ] = operation.nodes

  assert sub_operation.inputs == [ir.Parameter(name: "in", typename: "String")]
  assert sub_operation.outputs == [ir.Return(name: "out", typename: "Int")]

  let assert [
    ir.Edge(
      from: ir.PrimitiveOutput(value: ir.StringPrimitive("123")),
      to: ir.Input(path: ["so", "in"]),
    ),
    ir.Edge(
      from: ir.Output(path: ["so", "out"]),
      to: ir.Input(path: ["m", "l"]),
    ),
    ir.Edge(from: ir.Output(path: ["in"]), to: ir.Input(path: ["m", "r"])),
    ir.Edge(from: ir.Output(path: ["m", "value"]), to: ir.Input(path: ["out"])),
  ] = operation.edges
}

pub fn compile_ignores_unknown_node_port_registration_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l m.value -> .out }"

  let compiler =
    compiler.new(
      schema.new()
      |> schema.add_typename("Int")
      |> schema.add_node("Math"),
    )

  let assert Error(error) = compiler.compile(compiler, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(
        resolver_diagnostic.UnknownInput([
          "m",
          "l",
        ]),
      ),
      span: source.Span(start: 38, end: 41),
    )
}

pub fn compile_rejects_port_typename_mismatch_test() {
  let operation_source = "-> out: Int { m = Math m.value -> .out }"
  let compiler =
    compiler.new(
      schema.new()
      |> schema.add_typenames(["Int", "String"])
      |> schema.add_node("Math")
      |> schema.add_outputs(reference.Node(0), [
        #("value", reference.Typename(1)),
      ]),
    )

  let assert Error(error) = compiler.compile(compiler, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypecheckerDiagnostic(
        typechecker_diagnostic.TypeMismatch(
          expected: reference.Typename(0),
          found: reference.Typename(1),
        ),
      ),
      span: source.Span(start: 23, end: 38),
    )
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let compiler = compiler.new(schema.new())

  let assert Error(error) = compiler.compile(compiler, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let compiler = compiler.new(schema.new())

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
  let operation_source = "-> out: Int {}"
  let compiler = compiler.new(schema.new())

  let assert Error(error) = compiler.compile(compiler, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownTypename(
        "Int",
      )),
      span: source.Span(start: 8, end: 11),
    )
}
