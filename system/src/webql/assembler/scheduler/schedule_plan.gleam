import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import webql/assembler/linker/program
import webql/assembler/plan
import webql/assembler/scheduler/diagnostic
import webql/assembler/scheduler/schedule_route
import webql/assembler/scheduler/topology

/// Builds an executable plan from a linker program.
pub fn schedule(
  program: program.Program(task),
) -> Result(plan.Plan(task), diagnostic.Diagnostic) {
  let program.Program(nodes:, edges:) = program

  let dependencies =
    nodes
    |> dict.keys()
    |> list.fold(dict.new(), fn(dependencies, node) {
      dict.insert(dependencies, node, set.new())
    })

  let dependencies =
    list.fold(edges, dependencies, fn(dependencies, edge) {
      schedule_route.schedule(dependencies, edge)
    })

  use batches <- result.try(topology.topology(topology.Graph(dependencies:)))
  use batches <- result.try(schedule_batches(batches, nodes))

  let edges = schedule_edges(edges)
  Ok(plan.Plan(edges:, batches:))
}

// PRIVATE FUNCTIONS
// =================
fn schedule_edges(edges: List(program.Edge)) {
  list.map(edges, fn(edge) {
    case edge {
      program.Edge(
        source: program.Output(path: source),
        target: program.Input(path: target),
      ) ->
        plan.Edge(
          source: plan.Output(path: source),
          target: plan.Input(path: target),
        )

      program.Edge(
        source: program.Literal(value:),
        target: program.Input(path: target),
      ) ->
        plan.Edge(
          source: plan.Literal(value:),
          target: plan.Input(path: target),
        )
    }
  })
}

fn schedule_batches(
  batches: List(List(String)),
  nodes: dict.Dict(String, program.Node(task)),
) -> Result(List(plan.Batch(task)), diagnostic.Diagnostic) {
  case batches {
    [batch, ..batches] -> {
      use steps <- result.try(schedule_batch(batch, nodes, []))
      use batches <- result.try(schedule_batches(batches, nodes))

      Ok([plan.Batch(steps:), ..batches])
    }

    [] -> Ok([])
  }
}

fn schedule_batch(
  batch: List(String),
  nodes: dict.Dict(String, program.Node(task)),
  steps: List(plan.Step(task)),
) -> Result(List(plan.Step(task)), diagnostic.Diagnostic) {
  case batch {
    [name, ..batch] -> {
      use node <- result.try(schedule_step(nodes, name))
      schedule_batch(batch, nodes, [plan.Step(name:, node:), ..steps])
    }

    [] -> Ok(list.reverse(steps))
  }
}

fn schedule_step(
  nodes: dict.Dict(String, program.Node(task)),
  node: String,
) -> Result(plan.Node(task), diagnostic.Diagnostic) {
  case dict.get(nodes, node) {
    Ok(node) -> schedule_node(node)
    Error(_nil) -> Error(diagnostic.Diagnostic(kind: diagnostic.InvalidPlan))
  }
}

fn schedule_node(
  node: program.Node(task),
) -> Result(plan.Node(task), diagnostic.Diagnostic) {
  case node {
    program.Node(resolver:) -> Ok(plan.Node(resolver:))

    program.Supernode(program: program) -> {
      use plan <- result.try(schedule(program))
      Ok(plan.Supernode(plan:))
    }
  }
}
