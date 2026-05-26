import webql/compiler/lowerer/lower_binding
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_external_node_binding_test() {
  let binding =
    hir.Binding(
      name: "m",
      value: hir.NodeValue(
        name: "Math",
        reference: reference.Node(0),
        span: source.Span(start: 4, end: 8),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 8),
    )

  assert lower_binding.lower(binding, []) == graph.Node(name: "m", node: "Math")
}

pub fn lower_inline_node_binding_test() {
  let operation = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])

  let binding =
    hir.Binding(
      name: "inner",
      value: hir.NodeValue(
        name: "Inner",
        reference: reference.Node(0),
        span: source.Span(start: 8, end: 13),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 13),
    )

  assert lower_binding.lower(binding, [#("Inner", operation)])
    == graph.Supernode(name: "inner", graph: operation)
}
