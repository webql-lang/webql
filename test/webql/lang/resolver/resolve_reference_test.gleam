import gleam/dict
import gleam/option
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_reference
import webql/lang/source

pub fn resolve_output_node_port_reference_returns_node_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.from_list([
          #(#(option.Some("math"), "out"), reference.Port(0)),
        ]),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.NodePortReference(
    alias: "math",
    port: reference.Port(0),
    name: "out",
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "out",
        span: source.Span(0, 8),
      ),
    )
}

pub fn resolve_output_node_port_reference_returns_unknown_reference_when_node_output_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownReference(owner: option.Some("math"), name: "out"),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "out",
        span: source.Span(0, 8),
      ),
    )
}

pub fn resolve_output_operation_port_reference_returns_operation_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.from_list([
          #(#(option.None, "out"), reference.Port(0)),
        ]),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.OperationPortReference(
    port: reference.Port(0),
    name: "out",
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.OperationPortReference(port: "out", span: source.Span(0, 3)),
    )
}

pub fn resolve_output_operation_port_reference_returns_unknown_reference_when_output_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownReference(owner: option.None, name: "out"),
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.OperationPortReference(port: "out", span: source.Span(0, 3)),
    )
}

pub fn resolve_output_value_reference_delegates_to_resolve_value_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let assert Ok(ast.ValueReference(
    value: ast.IntValue(value: 42, span: source.Span(0, 2)),
    typename: reference.Type(0),
    span: source.Span(0, 2),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.ValueReference(
        value: parser_ast.IntValue(value: 42, span: source.Span(0, 2)),
        span: source.Span(0, 2),
      ),
    )
}

pub fn resolve_input_node_port_reference_returns_node_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.from_list([
          #(#(option.Some("math"), "value"), reference.Port(0)),
        ]),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.NodePortReference(
    alias: "math",
    port: reference.Port(0),
    name: "value",
    span: source.Span(0, 10),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "value",
        span: source.Span(0, 10),
      ),
    )
}

pub fn resolve_input_node_port_reference_returns_unknown_reference_when_node_input_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownReference(owner: option.Some("math"), name: "value"),
    span: source.Span(0, 10),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.NodePortReference(
        alias: "math",
        port: "value",
        span: source.Span(0, 10),
      ),
    )
}

pub fn resolve_input_operation_port_reference_returns_operation_port_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.from_list([
          #(#(option.None, "value"), reference.Port(0)),
        ]),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.OperationPortReference(
    port: reference.Port(0),
    name: "value",
    span: source.Span(0, 5),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.OperationPortReference(port: "value", span: source.Span(0, 5)),
    )
}

pub fn resolve_input_operation_port_reference_returns_unknown_reference_when_input_is_missing_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownReference(owner: option.None, name: "value"),
    span: source.Span(0, 5),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.OperationPortReference(port: "value", span: source.Span(0, 5)),
    )
}

pub fn resolve_input_value_reference_delegates_to_resolve_value_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let assert Ok(ast.ValueReference(
    value: ast.IntValue(value: 42, span: source.Span(0, 2)),
    typename: reference.Type(0),
    span: source.Span(0, 2),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.ValueReference(
        value: parser_ast.IntValue(value: 42, span: source.Span(0, 2)),
        span: source.Span(0, 2),
      ),
    )
}
