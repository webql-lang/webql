import gleam/list
import webql/compiler/lowerer/lower_edge
import webql/compiler/lowerer/lower_node
import webql/compiler/lowerer/lower_parameter
import webql/compiler/lowerer/lower_return
import webql/compiler/resolver
import webql/graph

/// Lowers a resolved graph into IR.
pub fn lower(graph: resolver.Graph) -> graph.Graph {
  let supernodes = lower_supernodes(graph.nodes)

  graph.Graph(
    parameters: list.map(graph.parameters, lower_parameter.lower),
    returns: list.map(graph.returns, lower_return.lower),
    nodes: lower_nodes(graph.nodes, supernodes),
    edges: list.map(graph.edges, lower_edge.lower),
  )
}

// PRIVATE FUNCTIONS
// =================
fn lower_supernodes(
  nodes: List(resolver.Node),
) -> List(#(String, graph.Graph)) {
  case nodes {
    [resolver.Supernode(name:, graph: graph, ..), ..nodes] -> [
      #(name, lower(graph)),
      ..lower_supernodes(nodes)
    ]

    [resolver.Node(..), ..nodes] -> lower_supernodes(nodes)
    [] -> []
  }
}

fn lower_nodes(
  nodes: List(resolver.Node),
  supernodes: List(#(String, graph.Graph)),
) -> List(graph.Node) {
  case nodes {
    [resolver.Supernode(..), ..nodes] -> lower_nodes(nodes, supernodes)

    [resolver.Node(name:, node:, ..), ..nodes] -> {
      let node = lower_node.lower(name, node, supernodes)
      [node, ..lower_nodes(nodes, supernodes)]
    }

    [] -> []
  }
}
