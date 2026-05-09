import gleam/dict
import gleam/result
import webql/document
import webql/engine/assembler/linker/diagnostic
import webql/engine/assembler/linker/link_node
import webql/engine/assembler/linker/link_route
import webql/engine/assembler/linker/program
import webql/graph

/// Links a graph module into a scheduler program.
pub fn link(
  module: graph.Module,
  document: document.Document,
) -> Result(program.Program, diagnostic.Diagnostic) {
  link_program(module.operation, document)
}

// PRIVATE FUNCTIONS
// =================
pub fn link_program(operation: graph.Operation, document: document.Document) {
  let graph.Operation(nodes:, edges:, ..) = operation

  use nodes <- result.try(link_nodes(nodes, document, dict.new()))
  let routes = link_route.link(edges)

  Ok(program.Program(nodes:, routes:))
}

// PRIVATE FUNCTIONS
// =================
fn link_nodes(
  nodes: List(graph.Node),
  document: document.Document,
  linked: dict.Dict(String, program.Resolver),
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
      use program <- result.try(link_program(operation, document))
      Ok(#(name, program.InlineResolver(program:)))
    }
  }
}
