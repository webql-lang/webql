import gleam/dict
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_reference
import webql/lang/source

pub fn resolve_output_access_reference_returns_access_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.new(),
        outputs: dict.from_list([
          #(["math", "out"], reference.Access(0)),
        ]),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.Access(
    path: ["math", "out"],
    reference: reference.Access(0),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.Access(path: ["math", "out"], span: source.Span(0, 8)),
    )
}

pub fn resolve_output_access_returns_unknown_access_when_output_is_missing_test() {
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
    kind: diagnostic.UnknownAccess(path: ["math", "out"]),
    span: source.Span(0, 8),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.Access(path: ["math", "out"], span: source.Span(0, 8)),
    )
}

pub fn resolve_output_access_returns_unknown_access_when_path_is_missing_test() {
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
    kind: diagnostic.UnknownAccess(path: ["out"]),
    span: source.Span(0, 3),
  )) =
    resolve_reference.resolve_output(
      registry,
      parser_ast.Access(path: ["out"], span: source.Span(0, 3)),
    )
}

pub fn resolve_input_access_reference_returns_access_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.from_list([
          #(["math", "value"], reference.Access(0)),
        ]),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.Access(
    path: ["math", "value"],
    reference: reference.Access(0),
    span: source.Span(0, 10),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.Access(path: ["math", "value"], span: source.Span(0, 10)),
    )
}

pub fn resolve_input_access_returns_unknown_access_when_input_is_missing_test() {
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
    kind: diagnostic.UnknownAccess(path: ["math", "value"]),
    span: source.Span(0, 10),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.Access(path: ["math", "value"], span: source.Span(0, 10)),
    )
}

pub fn resolve_input_single_segment_access_returns_access_reference_test() {
  let registry =
    registry.Registry(
      ..registry.new(typenames: ["Int"], nodes: []),
      environment: registry.Environment(
        inputs: dict.from_list([
          #(["value"], reference.Access(0)),
        ]),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  let assert Ok(ast.Access(
    path: ["value"],
    reference: reference.Access(0),
    span: source.Span(0, 5),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.Access(path: ["value"], span: source.Span(0, 5)),
    )
}

pub fn resolve_input_primitive_reference_delegates_to_resolve_primitive_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let assert Ok(ast.Literal(
    value: ast.Int(value: 42, span: source.Span(0, 2)),
    reference: reference.Typename(0),
    span: source.Span(0, 2),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.Literal(
        value: parser_ast.Int(value: 42, span: source.Span(0, 2)),
        span: source.Span(0, 2),
      ),
    )
}

pub fn resolve_input_node_reference_returns_unknown_node_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.UnknownNode("Math"),
    span: source.Span(0, 4),
  )) =
    resolve_reference.resolve_input(
      registry,
      parser_ast.Node(name: "Math", span: source.Span(0, 4)),
    )
}
