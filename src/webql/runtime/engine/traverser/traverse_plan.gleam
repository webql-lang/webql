import gleam/dict
import gleam/dynamic
import gleam/result
import webql/runtime/engine/plan
import webql/runtime/engine/traverser/diagnostic
import webql/runtime/engine/traverser/progress
import webql/runtime/engine/traverser/traverse_batch

/// Runs an executable plan.
pub fn traverse(
  plan: plan.Plan,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let plan.Plan(routes:, batches:) = plan

  let progress = progress.add_parameters(progress.new(), parameters)
  use progress <- result.try(traverse_batches(batches, routes, progress))

  case progress.get_returns(progress, plan.routes) {
    Ok(returns) -> Ok(returns)
    Error(_nil) -> Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn))
  }
}

// PRIVATE FUNCTIONS
// =================
fn traverse_batches(
  batches: List(plan.Batch),
  routes: List(plan.Route),
  progress: progress.Progress,
) {
  case batches {
    [plan.Batch(batch:), ..batches] -> {
      use progress <- result.try(traverse_batch.traverse(
        batch,
        routes,
        progress,
        traverse,
      ))

      traverse_batches(batches, routes, progress)
    }

    [] -> Ok(progress)
  }
}
