import gleam/list
import webql/compiler/lowerer/lower_edge
import webql/compiler/lowerer/lower_parameter
import webql/compiler/lowerer/lower_return
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved node into an IR node.
pub fn lower(
  node: hir.Node,
  supernodes: List(#(String, graph.Graph)),
) -> graph.Node {
  case node {
    hir.Supernode(name:, graph: graph, ..) ->
      graph.Supernode(name:, graph: lower_graph(graph))

    hir.Node(name:, node:, ..) -> lower_node(name, node, supernodes)
  }
}

// PRIVATE FUNCTIONS
// =================
fn lower_node(
  name: String,
  node: String,
  supernodes: List(#(String, graph.Graph)),
) {
  case supernodes {
    [#(supernode, graph), ..] if supernode == node ->
      graph.Supernode(name:, graph:)

    [_, ..supernodes] -> lower_node(name, node, supernodes)
    [] -> graph.Node(name:, node:)
  }
}

fn lower_graph(graph: hir.Graph) -> graph.Graph {
  graph.Graph(
    parameters: list.map(graph.parameters, lower_parameter.lower),
    returns: list.map(graph.returns, lower_return.lower),
    nodes: list.map(graph.nodes, fn(node) { lower(node, []) }),
    edges: list.map(graph.edges, lower_edge.lower),
  )
}
