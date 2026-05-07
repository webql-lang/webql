import gleam/dict
import gleam/result
import webql/document
import webql/engine/system/linker/diagnostic
import webql/engine/system/linker/link_node
import webql/engine/system/linker/link_route
import webql/engine/system/linker/plan
import webql/graph

/// Links a graph module into a scheduler plan.
pub fn link(
  module: graph.Module,
  document: document.Document,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  link_plan(module.operation, document)
}

// PRIVATE FUNCTIONS
// =================
pub fn link_plan(operation: graph.Operation, document: document.Document) {
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
      use #(name, resolver) <- result.try(link_node(node, document))
      link_nodes(nodes, document, dict.insert(linked, name, resolver))
    }

    [] -> Ok(linked)
  }
}

fn link_node(node: graph.Node, document: document.Document) {
  case node {
    graph.ExternalNode(name:, node:) -> link_node.link(name, node, document)

    graph.InlineNode(name:, operation:) -> {
      use plan <- result.try(link_plan(operation, document))
      Ok(#(name, plan.InlineResolver(plan:)))
    }
  }
}
