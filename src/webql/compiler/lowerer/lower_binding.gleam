import gleam/option
import webql/compiler/ir
import webql/compiler/resolver/ast

/// Lowers a resolved binding into an IR node when it binds a node value.
pub fn lower(
  binding: ast.Binding,
  definitions: List(#(String, ir.Operation)),
) -> ir.Node {
  case binding.value {
    ast.NodeValue(name: node, ..) ->
      lower_node_binding(binding.name, node, definitions)
  }
}

// PRIVATE FUNCTIONS
// =================
fn lower_node_binding(
  name: String,
  node: String,
  definitions: List(#(String, ir.Operation)),
) -> ir.Node {
  case lower_node(definitions, node) {
    option.Some(operation) -> ir.InlineNode(name:, operation:)
    option.None -> ir.ExternalNode(name:, node:)
  }
}

fn lower_node(
  definitions: List(#(String, ir.Operation)),
  name: String,
) -> option.Option(ir.Operation) {
  case definitions {
    [#(definition, operation), ..] if definition == name ->
      option.Some(operation)

    [_definition, ..definitions] -> lower_node(definitions, name)
    [] -> option.None
  }
}
