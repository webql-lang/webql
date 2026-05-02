import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/result
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress
import webql/engine/runner/propagator
import webql/engine/runner/run_batch

/// Runs an executable plan.
pub fn run(
  plan: plan.Plan,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let plan.Plan(routes:, batches:) = plan

  let progress =
    progress.new()
    |> progress.add_values([], parameters)
    |> register_routes(routes)

  use progress <- result.try(run_batches(batches, routes, progress))

  let progress = register_routes(progress, routes)
  let returns = dict.new()

  map_returns(routes, progress, returns)
}

// PRIVATE FUNCTIONS
// =================
fn run_batches(
  batches: List(plan.Batch),
  routes: List(plan.Route),
  progress: progress.Progress,
) {
  case batches {
    [plan.Batch(batch:), ..batches] -> {
      use progress <- result.try(run_batch.run(batch, routes, progress, run))

      let progress = propagator.propagate(progress, routes)
      run_batches(batches, routes, progress)
    }

    [] -> Ok(progress)
  }
}

fn register_routes(progress: progress.Progress, routes: List(plan.Route)) {
  list.fold(routes, progress, fn(progress, _route) {
    propagator.propagate(progress, routes)
  })
}

fn map_returns(
  routes: List(plan.Route),
  progress: progress.Progress,
  returns: dict.Dict(String, dynamic.Dynamic),
) {
  case routes {
    [route, ..routes] -> {
      map_return(route, routes, progress, returns)
    }

    [] -> Ok(returns)
  }
}

fn map_return(
  route: plan.Route,
  routes: List(plan.Route),
  progress: progress.Progress,
  returns: dict.Dict(String, dynamic.Dynamic),
) {
  case route.to {
    [output] -> {
      map_return_to(output, routes, progress, returns)
    }

    _target -> map_returns(routes, progress, returns)
  }
}

fn map_return_to(
  output: String,
  routes: List(plan.Route),
  progress: progress.Progress,
  returns: dict.Dict(String, dynamic.Dynamic),
) {
  case progress.get_value(progress, [output]) {
    Ok(value) ->
      map_returns(routes, progress, dict.insert(returns, output, value))

    Error(_nil) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingReturn(output: output)),
      )
  }
}
