import gleam/dict
import gleam/option
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_reference
import webql/lang/source

pub fn resolve_node_port_reference_returns_node_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"]),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.from_list([
          #(#(option.Some("math"), "out"), reference.Port(0)),
        ]),
        nodes: dict.from_list([
          #("math", reference.Node(0)),
        ]),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.NodePortReference(
    node: reference.Node(0),
    alias: "math",
    port: reference.Port(0),
    name: "out",
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "out",
        span: source.Span(0, 8),
      ),
    )
}

pub fn resolve_node_port_reference_returns_unknown_node_when_alias_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"]),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        nodes: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownNode(alias: "math"),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "out",
        span: source.Span(0, 8),
      ),
    )
}

pub fn resolve_node_port_reference_returns_unknown_port_when_node_output_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"]),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        nodes: dict.from_list([
          #("math", reference.Node(0)),
        ]),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownPort(owner: option.Some("math"), name: "out"),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "out",
        span: source.Span(0, 8),
      ),
    )
}

pub fn resolve_operation_port_reference_returns_operation_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"]),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.from_list([
          #(#(option.None, "out"), reference.Port(0)),
        ]),
        nodes: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.OperationPortReference(
    port: reference.Port(0),
    name: "out",
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.OperationPortReference(port: "out", span: source.Span(0, 3)),
    )
}

pub fn resolve_operation_port_reference_returns_unknown_port_when_output_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"]),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        nodes: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownPort(owner: option.None, name: "out"),
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.OperationPortReference(port: "out", span: source.Span(0, 3)),
    )
}

pub fn resolve_value_reference_delegates_to_resolve_value_test() {
  let registry = registry.new(typenames: ["Int"])

  let assert Ok(ast.ValueReference(
    value: ast.IntValue(value: 42, span: source.Span(0, 2)),
    typename: reference.Type(0),
    span: source.Span(0, 2),
  )) =
    resolve_reference.resolve(
      registry,
      parser_ast.ValueReference(
        value: parser_ast.IntValue(value: 42, span: source.Span(0, 2)),
        span: source.Span(0, 2),
      ),
    )
}
