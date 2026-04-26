import webql/compiler/ir
import webql/compiler/resolver/ast

/// Lowers a resolved binding into an IR node when it binds a node value.
pub fn lower(
  binding: ast.Binding,
  definitions: List(#(String, ir.Operation)),
) -> ir.Node {
  case definitions {
    [#(definition, operation), ..] if definition == binding.value.name ->
      ir.InlineNode(name: binding.name, operation:)

    [_definition, ..definitions] -> lower(binding, definitions)
    [] -> ir.ExternalNode(name: binding.name, node: binding.value.name)
  }
}
