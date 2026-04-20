import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_binding
import webql/compiler/source

pub fn resolve_node_binding_test() {
  let registry = registry.add_node(registry.new(), "Math")

  let binding_to_resolve =
    parser_ast.Binding(
      name: "math",
      value: parser_ast.NodeValue(
        name: "Math",
        span: source.Span(start: 7, end: 11),
      ),
      span: source.Span(start: 0, end: 11),
    )

  let assert Ok(binding) =
    resolve_binding.resolve(registry, binding_to_resolve, reference.Binding(0))

  assert binding
    == ast.Binding(
      name: "math",
      value: ast.NodeValue(
        name: "Math",
        reference: reference.Node(0),
        span: source.Span(start: 7, end: 11),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 11),
    )
}

pub fn resolve_primitive_binding_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let binding_to_resolve =
    parser_ast.Binding(
      name: "count",
      value: parser_ast.PrimitiveValue(
        value: parser_ast.Int(value: 123, span: source.Span(start: 8, end: 11)),
        span: source.Span(start: 8, end: 11),
      ),
      span: source.Span(start: 0, end: 11),
    )

  let assert Ok(binding) =
    resolve_binding.resolve(registry, binding_to_resolve, reference.Binding(0))

  assert binding
    == ast.Binding(
      name: "count",
      value: ast.PrimitiveValue(
        value: ast.Int(value: 123, span: source.Span(start: 8, end: 11)),
        typename: reference.Typename(0),
        span: source.Span(start: 8, end: 11),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 11),
    )
}

pub fn resolve_returns_duplicate_binding_for_existing_binding_test() {
  let registry = registry.add_binding(registry.new(), ["math"])

  let binding_to_resolve =
    parser_ast.Binding(
      name: "math",
      value: parser_ast.NodeValue(
        name: "Math",
        span: source.Span(start: 7, end: 11),
      ),
      span: source.Span(start: 0, end: 11),
    )

  let assert Error(error) =
    resolve_binding.resolve(registry, binding_to_resolve, reference.Binding(1))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateBinding("math"),
      span: source.Span(start: 0, end: 11),
    )
}
