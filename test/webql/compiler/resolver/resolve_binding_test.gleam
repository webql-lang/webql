import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_binding
import webql/compiler/source
import webql/loader/schema

pub fn resolve_node_binding_test() {
  let schema = schema.add_node(schema.new(), "Math")

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
    resolve_binding.resolve(
      environment.new(schema),
      context.new(),
      binding_to_resolve,
      reference.Binding(0),
    )

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

pub fn resolve_returns_duplicate_binding_for_existing_binding_test() {
  let context = context.add_binding(context.new(), "math")

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
    resolve_binding.resolve(
      environment.new(schema.new()),
      context,
      binding_to_resolve,
      reference.Binding(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateBinding("math"),
      span: source.Span(start: 0, end: 11),
    )
}
