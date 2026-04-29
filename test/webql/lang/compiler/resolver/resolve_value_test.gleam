import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_value
import webql/lang/compiler/source

pub fn resolve_node_value_test() {
  let schema = environment.add_node(environment.new(), "Math")

  let value_to_resolve =
    parser_ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))

  let assert Ok(value) = resolve_value.resolve(schema, value_to_resolve)

  assert value
    == ast.NodeValue(
      name: "Math",
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_returns_unknown_node_for_missing_node_value_test() {
  let schema = environment.new()

  let value_to_resolve =
    parser_ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))

  let assert Error(error) = resolve_value.resolve(schema, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownNode("Math"),
      span: source.Span(start: 0, end: 4),
    )
}
