import webql/graph
import webql/lang/compiler/resolver/ast

/// Lowers a resolved binding into an IR node when it binds a node value.
pub fn lower(
  binding: ast.Binding,
  definitions: List(#(String, graph.Operation)),
) -> graph.Node {
  case definitions {
    [#(definition, operation), ..] if definition == binding.value.name ->
      graph.InlineNode(name: binding.name, operation:)

    [_definition, ..definitions] -> lower(binding, definitions)
    [] -> graph.ExternalNode(name: binding.name, node: binding.value.name)
  }
}
