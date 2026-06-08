import webql/compiler/lowerer/lower_node
import webql/graph

pub fn lower_node_test() {
  assert lower_node.lower("m", "Math", [])
    == graph.Node(name: "m", node: "Math")
}

pub fn lower_supernode_test() {
  let graph = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])

  assert lower_node.lower("inner", "Inner", [#("Inner", graph)])
    == graph.Supernode(name: "inner", graph: graph)
}
