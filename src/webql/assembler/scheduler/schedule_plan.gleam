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
  let program.Program(nodes:, routes:) = program

  let dependencies =
    nodes
    |> dict.keys()
    |> list.fold(dict.new(), fn(dependencies, node) {
      dict.insert(dependencies, node, set.new())
    })

  let dependencies =
    list.fold(routes, dependencies, fn(dependencies, route) {
      schedule_route.schedule(dependencies, route)
    })

  use batches <- result.try(topology.topology(topology.Graph(dependencies:)))
  use batches <- result.try(schedule_batches(batches, nodes))

  let routes = schedule_routes(routes)
  Ok(plan.Plan(routes:, batches:))
}

// PRIVATE FUNCTIONS
// =================
fn schedule_routes(routes: List(program.Route)) {
  list.map(routes, fn(route) {
    case route {
      program.Route(from:, to:) -> plan.Route(from:, to:)
      program.Constant(value:, to:) -> plan.Constant(value:, to:)
    }
  })
}

fn schedule_batches(
  batches: List(List(String)),
  nodes: dict.Dict(String, program.Resolver(task)),
) -> Result(List(plan.Batch(task)), diagnostic.Diagnostic) {
  case batches {
    [batch, ..batches] -> {
      use batch <- result.try(schedule_batch(batch, nodes, []))
      use batches <- result.try(schedule_batches(batches, nodes))

      Ok([plan.Batch(batch:), ..batches])
    }

    [] -> Ok([])
  }
}

fn schedule_batch(
  batch: List(String),
  nodes: dict.Dict(String, program.Resolver(task)),
  steps: List(plan.Step(task)),
) -> Result(List(plan.Step(task)), diagnostic.Diagnostic) {
  case batch {
    [node, ..batch] -> {
      use resolver <- result.try(schedule_step(nodes, node))
      schedule_batch(batch, nodes, [plan.Step(name: node, resolver:), ..steps])
    }

    [] -> Ok(list.reverse(steps))
  }
}

fn schedule_step(
  nodes: dict.Dict(String, program.Resolver(task)),
  node: String,
) -> Result(plan.Resolver(task), diagnostic.Diagnostic) {
  case dict.get(nodes, node) {
    Ok(resolver) -> schedule_resolver(resolver)
    Error(_nil) -> Error(diagnostic.Diagnostic(kind: diagnostic.InvalidPlan))
  }
}

fn schedule_resolver(
  resolver: program.Resolver(task),
) -> Result(plan.Resolver(task), diagnostic.Diagnostic) {
  case resolver {
    program.FunctionResolver(function) -> Ok(plan.FunctionResolver(function:))

    program.InlineResolver(program: program) -> {
      use plan <- result.try(schedule(program))
      Ok(plan.InlineResolver(plan:))
    }
  }
}
