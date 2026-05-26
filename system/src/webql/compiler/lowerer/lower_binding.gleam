import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved binding into an IR node when it binds a node value.
pub fn lower(
  binding: hir.Binding,
  definitions: List(#(String, graph.Graph)),
) -> graph.Node {
  case definitions {
    [#(definition, graph), ..] if definition == binding.value.name ->
      graph.Supernode(name: binding.name, graph:)

    [_definition, ..definitions] -> lower(binding, definitions)
    [] -> graph.Node(name: binding.name, node: binding.value.name)
  }
}
