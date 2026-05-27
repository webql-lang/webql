import webql/compiler/lowerer/lower_node
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_external_node_node_test() {
  let node =
    hir.Node(
      name: "m",
      node: "Math",
      operation: reference.Operation(0),
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 8),
    )

  assert lower_node.lower(node, []) == graph.Node(name: "m", node: "Math")
}

pub fn lower_inline_node_node_test() {
  let graph = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])

  let node =
    hir.Node(
      name: "inner",
      node: "Inner",
      operation: reference.Operation(0),
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 13),
    )

  assert lower_node.lower(node, [#("Inner", graph)])
    == graph.Supernode(name: "inner", graph: graph)
}
