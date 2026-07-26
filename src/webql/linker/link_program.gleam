import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_batch
import webql/linker/link_edge
import webql/linker/link_route
import webql/linker/topology
import webql/program
import webql/schema

/// Links a graph and schema into a program.
pub fn link(
  graph: graph.Graph,
  schema: schema.Schema,
) -> Result(program.Program, diagnostic.Diagnostic) {
  let graph.Graph(nodes:, edges:, ..) = graph

  let nodes =
    list.fold(nodes, dict.new(), fn(nodes, node) {
      let name = case node {
        graph.Node(name:, ..) -> name
        graph.Supernode(name:, ..) -> name
      }

      dict.insert(nodes, name, node)
    })

  let graph =
    nodes
    |> dict.keys()
    |> list.fold(dict.new(), fn(dependencies, node) {
      dict.insert(dependencies, node, set.new())
    })

  let dependencies =
    list.fold(edges, graph, fn(dependencies, edge) {
      link_route.link(dependencies, edge)
    })

  use topology <- result.try(topology.topology(topology.Graph(dependencies:)))
  use batches <- result.try(link_batch.link(topology, nodes, schema, link))

  let edges = link_edge.link(edges)
  Ok(program.Program(edges:, batches:))
}
