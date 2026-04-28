import webql/graph
import webql/lang/compiler/lowerer/lower_binding
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_external_node_binding_test() {
  let binding =
    ast.Binding(
      name: "m",
      value: ast.NodeValue(
        name: "Math",
        reference: reference.Node(0),
        span: source.Span(start: 4, end: 8),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 8),
    )

  assert lower_binding.lower(binding, [])
    == graph.ExternalNode(name: "m", node: "Math")
}

pub fn lower_inline_node_binding_test() {
  let operation = graph.Operation(inputs: [], outputs: [], nodes: [], edges: [])

  let binding =
    ast.Binding(
      name: "inner",
      value: ast.NodeValue(
        name: "Inner",
        reference: reference.Node(0),
        span: source.Span(start: 8, end: 13),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 13),
    )

  assert lower_binding.lower(binding, [#("Inner", operation)])
    == graph.InlineNode(name: "inner", operation:)
}
