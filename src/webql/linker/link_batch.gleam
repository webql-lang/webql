import gleam/dict
import gleam/list
import gleam/result
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_node
import webql/plan
import webql/schema

/// Links topological batches into executable plan batches.
pub fn link(
  batches: List(List(String)),
  nodes: dict.Dict(String, graph.Node),
  schema: schema.Schema,
  link_graph: fn(graph.Graph, schema.Schema) ->
    Result(plan.Plan, diagnostic.Diagnostic),
) -> Result(List(plan.Batch), diagnostic.Diagnostic) {
  case batches {
    [batch, ..batches] -> {
      use steps <- result.try(link_steps(batch, nodes, schema, link_graph, []))
      use batches <- result.try(link(batches, nodes, schema, link_graph))

      Ok([plan.Batch(steps:), ..batches])
    }

    [] -> Ok([])
  }
}

// PRIVATE FUNCTIONS
// =================
fn link_steps(
  batch: List(String),
  nodes: dict.Dict(String, graph.Node),
  schema: schema.Schema,
  link_graph: fn(graph.Graph, schema.Schema) ->
    Result(plan.Plan, diagnostic.Diagnostic),
  steps: List(plan.Step),
) {
  case batch {
    [name, ..batch] -> {
      use node <- result.try(link_step(nodes, name, schema, link_graph))
      link_steps(batch, nodes, schema, link_graph, [
        plan.Step(name:, node:),
        ..steps
      ])
    }

    [] -> Ok(list.reverse(steps))
  }
}

fn link_step(
  nodes: dict.Dict(String, graph.Node),
  node: String,
  schema: schema.Schema,
  link_graph: fn(graph.Graph, schema.Schema) ->
    Result(plan.Plan, diagnostic.Diagnostic),
) {
  case dict.get(nodes, node) {
    Ok(graph.Node(node:, ..)) -> link_node.link(node, schema)

    Ok(graph.Supernode(graph:, ..)) -> {
      use plan <- result.try(link_graph(graph, schema))
      Ok(plan.Supernode(plan:))
    }

    Error(_nil) -> Error(diagnostic.Diagnostic(kind: diagnostic.InvalidPlan))
  }
}
