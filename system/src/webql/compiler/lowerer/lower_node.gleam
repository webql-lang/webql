import webql/graph

/// Lowers a resolved node reference into an IR node.
pub fn lower(
  name: String,
  node: String,
  supernodes: List(#(String, graph.Graph)),
) -> graph.Node {
  case supernodes {
    [#(supernode, graph), ..] if supernode == node ->
      graph.Supernode(name:, graph:)

    [_supernode, ..supernodes] -> lower(name, node, supernodes)
    [] -> graph.Node(name:, node:)
  }
}
