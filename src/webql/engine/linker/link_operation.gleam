import gleam/dict
import gleam/result
import webql/document
import webql/engine/linker/diagnostic
import webql/engine/linker/link_node
import webql/engine/linker/link_route
import webql/engine/linker/plan
import webql/graph

/// Links a graph operation into a scheduler plan.
pub fn link(
  operation: graph.Operation,
  document: document.Document,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  let graph.Operation(nodes:, edges:, ..) = operation

  use nodes <- result.try(link_nodes(nodes, document, dict.new()))
  let routes = link_route.link(edges)

  Ok(plan.Plan(nodes:, routes:))
}

// PRIVATE FUNCTIONS
// =================
fn link_nodes(
  nodes: List(graph.Node),
  document: document.Document,
  linked: dict.Dict(String, plan.Resolver),
) {
  case nodes {
    [node, ..nodes] -> {
      use #(name, resolver) <- result.try(link_operation_node(node, document))
      link_nodes(nodes, document, dict.insert(linked, name, resolver))
    }

    [] -> Ok(linked)
  }
}

fn link_operation_node(node: graph.Node, document: document.Document) {
  case node {
    graph.ExternalNode(name:, node:) -> link_node.link(name, node, document)

    graph.InlineNode(name:, operation:) -> {
      use plan <- result.try(link(operation, document))
      Ok(#(name, plan.InlineResolver(plan:)))
    }
  }
}
