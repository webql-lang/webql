import gleam/list
import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_binding
import webql/lang/compiler/lowerer/lower_edge
import webql/lang/compiler/lowerer/lower_parameter
import webql/lang/compiler/lowerer/lower_return
import webql/lang/compiler/resolver/ast

/// Lowers a resolved operation into IR.
pub fn lower(operation: ast.Operation) -> ir.Operation {
  let definitions =
    list.map(operation.definitions, fn(definition) {
      #(definition.name, lower(definition.operation))
    })

  ir.Operation(
    inputs: list.map(operation.parameters, lower_parameter.lower),
    outputs: list.map(operation.returns, lower_return.lower),
    nodes: lower_nodes(operation.bindings, definitions),
    edges: list.map(operation.edges, lower_edge.lower),
  )
}

// PRIVATE FUNCTIONS
// =================
fn lower_nodes(
  bindings: List(ast.Binding),
  definitions: List(#(String, ir.Operation)),
) -> List(ir.Node) {
  case bindings {
    [binding, ..bindings] -> {
      let nodes = lower_nodes(bindings, definitions)
      let node = lower_binding.lower(binding, definitions)

      [node, ..nodes]
    }
    [] -> []
  }
}
