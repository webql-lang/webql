import gleam/dict
import gleam/dynamic
import gleam/result
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress
import webql/engine/runner/run_batch

/// Runs an executable plan.
pub fn run(
  plan: plan.Plan,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let plan.Plan(routes:, batches:) = plan

  let progress = progress.add_parameters(progress.new(), parameters)
  use progress <- result.try(run_batches(batches, routes, progress))

  case progress.get_returns(progress, plan.routes) {
    Ok(returns) -> Ok(returns)
    Error(_nil) -> Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn))
  }
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

      run_batches(batches, routes, progress)
    }

    [] -> Ok(progress)
  }
}
