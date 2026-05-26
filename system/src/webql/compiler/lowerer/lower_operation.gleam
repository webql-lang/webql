import gleam/list
import webql/compiler/lowerer/lower_binding
import webql/compiler/lowerer/lower_edge
import webql/compiler/lowerer/lower_parameter
import webql/compiler/lowerer/lower_return
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved operation into IR.
pub fn lower(operation: hir.Operation) -> graph.Graph {
  let definitions =
    list.map(operation.definitions, fn(definition) {
      #(definition.name, lower(definition.operation))
    })

  graph.Graph(
    parameters: list.map(operation.parameters, lower_parameter.lower),
    returns: list.map(operation.returns, lower_return.lower),
    nodes: lower_nodes(operation.bindings, definitions),
    edges: list.map(operation.edges, lower_edge.lower),
  )
}

// PRIVATE FUNCTIONS
// =================
fn lower_nodes(
  bindings: List(hir.Binding),
  definitions: List(#(String, graph.Graph)),
) -> List(graph.Node) {
  case bindings {
    [binding, ..bindings] -> {
      let nodes = lower_nodes(bindings, definitions)
      let node = lower_binding.lower(binding, definitions)

      [node, ..nodes]
    }
    [] -> []
  }
}
