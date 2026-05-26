import gleam/dict
import gleam/result
import webql/assembler/linker/diagnostic
import webql/assembler/linker/link_node
import webql/assembler/linker/link_route
import webql/assembler/linker/program
import webql/graph
import webql/schema

/// Links a graph module into a scheduler program.
pub fn link(
  module: graph.Module,
  schema: schema.Schema(task),
) -> Result(program.Program(task), diagnostic.Diagnostic) {
  link_program(module.operation, schema)
}

// PRIVATE FUNCTIONS
// =================
pub fn link_program(
  operation: graph.Operation,
  schema: schema.Schema(task),
) -> Result(program.Program(task), diagnostic.Diagnostic) {
  let graph.Operation(nodes:, edges:, ..) = operation

  use nodes <- result.try(link_nodes(nodes, schema, dict.new()))
  let routes = link_route.link(edges)

  Ok(program.Program(nodes:, routes:))
}

// PRIVATE FUNCTIONS
// =================
fn link_nodes(
  nodes: List(graph.Node),
  schema: schema.Schema(task),
  linked: dict.Dict(String, program.Resolver(task)),
) -> Result(dict.Dict(String, program.Resolver(task)), diagnostic.Diagnostic) {
  case nodes {
    [node, ..nodes] -> {
      use #(name, resolver) <- result.try(link_node(node, schema))
      link_nodes(nodes, schema, dict.insert(linked, name, resolver))
    }

    [] -> Ok(linked)
  }
}

fn link_node(
  node: graph.Node,
  schema: schema.Schema(task),
) -> Result(#(String, program.Resolver(task)), diagnostic.Diagnostic) {
  case node {
    graph.ExternalNode(name:, node:) -> link_node.link(name, node, schema)

    graph.InlineNode(name:, operation:) -> {
      use program <- result.try(link_program(operation, schema))
      Ok(#(name, program.InlineResolver(program:)))
    }
  }
}
