import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_binding
import webql/lang/compiler/source

pub fn resolve_node_binding_test() {
  let schema = environment.add_node(environment.new(), "Math")

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
      schema,
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
      environment.new(),
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
