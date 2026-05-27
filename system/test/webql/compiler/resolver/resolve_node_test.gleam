import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_node
import webql/compiler/source

pub fn resolve_node_node_test() {
  let schema = environment.add_operation(environment.new(), "Math")

  let node_to_resolve =
    ast.Node(name: "math", node: "Math", span: source.Span(start: 0, end: 11))

  let assert Ok(node) =
    resolve_node.resolve(
      schema,
      context.new(),
      node_to_resolve,
      reference.Node(0),
    )

  assert node
    == hir.Node(
      name: "math",
      node: "Math",
      operation: reference.Operation(0),
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 11),
    )
}

pub fn resolve_returns_duplicate_node_for_existing_node_test() {
  let context = context.add_node(context.new(), "math")

  let node_to_resolve =
    ast.Node(name: "math", node: "Math", span: source.Span(start: 0, end: 11))

  let assert Error(error) =
    resolve_node.resolve(
      environment.new(),
      context,
      node_to_resolve,
      reference.Node(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateNode("math"),
      span: source.Span(start: 0, end: 11),
    )
}
