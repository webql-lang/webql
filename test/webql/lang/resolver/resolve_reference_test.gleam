import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_reference
import webql/lang/source

pub fn resolve_access_reference_returns_access_reference_test() {
  let registry =
    registry.new()
    |> registry.add_typename("Int")
    |> registry.add_output(["math", "out"])

  let assert Ok(ast.OutputAccess(
    path: ["math", "out"],
    reference: reference.Output(0),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.PortOutput(path: ["math", "out"], span: source.Span(0, 8)),
    )
}

pub fn resolve_access_returns_unknown_access_when_output_is_missing_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownOutput(path: ["math", "out"]),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.PortOutput(path: ["math", "out"], span: source.Span(0, 8)),
    )
}

pub fn resolve_access_returns_unknown_access_when_path_is_missing_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownInput(path: ["out"]),
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.PortInput(path: ["out"], span: source.Span(0, 3)),
    )
}

pub fn resolve_access_returns_unknown_access_when_input_is_missing_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownOutput(path: ["math", "value"]),
    span: source.Span(0, 10),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.PortOutput(path: ["math", "value"], span: source.Span(0, 10)),
    )
}

pub fn resolve_single_segment_access_returns_access_reference_test() {
  let registry =
    registry.new()
    |> registry.add_typename("Int")
    |> registry.add_input(["value"])

  let assert Ok(ast.InputAccess(
    path: ["value"],
    reference: reference.Input(0),
    span: source.Span(0, 5),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.PortInput(path: ["value"], span: source.Span(0, 5)),
    )
}

pub fn resolve_primitive_reference_delegates_to_resolve_primitive_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let assert Ok(ast.Literal(
    value: ast.Int(value: 42, span: source.Span(0, 2)),
    reference: reference.Typename(0),
    span: source.Span(0, 2),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.PrimitiveOutput(
        value: parser_ast.Int(value: 42, span: source.Span(0, 2)),
        span: source.Span(0, 2),
      ),
    )
}

pub fn resolve_node_reference_returns_unknown_node_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownNode("Math"),
    span: source.Span(0, 4),
  )) =
    resolve_reference.resolve_value(
      registry,
      parser_ast.NodeValue(name: "Math", span: source.Span(0, 4)),
    )
}

pub fn resolve_node_reference_returns_node_reference_test() {
  let registry = registry.add_node(registry.new(), "Math")

  let assert Ok(ast.Node(
    name: "Math",
    reference: reference.Node(0),
    span: source.Span(0, 4),
  )) =
    resolve_reference.resolve_value(
      registry,
      parser_ast.NodeValue(name: "Math", span: source.Span(0, 4)),
    )
}

pub fn resolve_suboperation_reference_returns_suboperation_reference_test() {
  let sub_registry = registry.add_typename(registry.new(), "Int")
  let registry = registry.add_operation(registry.new(), "Math", sub_registry)

  let operation =
    parser_ast.Operation(
      parameters: [],
      returns: [],
      definitions: [],
      bindings: [],
      edges: [],
      span: source.Span(5, 18),
    )

  let assert Ok(ast.SubOperation(
    name: "Math",
    reference: reference.Operation(0),
    operation: ast.Operation(
      inputs: [],
      outputs: [],
      bindings: [],
      edges: [],
      span: source.Span(5, 18),
    ),
    span: source.Span(0, 18),
  )) =
    resolve_reference.resolve_definition(
      registry,
      parser_ast.Definition(name: "Math", operation:, span: source.Span(0, 18)),
    )
}

pub fn resolve_suboperation_reference_returns_unknown_operation_test() {
  let registry = registry.new()

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownOperation("Math"),
    span: source.Span(0, 18),
  )) =
    resolve_reference.resolve_definition(
      registry,
      parser_ast.Definition(
        name: "Math",
        operation: parser_ast.Operation(
          parameters: [],
          returns: [],
          definitions: [],
          bindings: [],
          edges: [],
          span: source.Span(5, 18),
        ),
        span: source.Span(0, 18),
      ),
    )
}
