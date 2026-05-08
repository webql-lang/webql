import gleam/dict
import gleam/dynamic
import gleam/result
import webql/engine/memory
import webql/engine/system/plan
import webql/engine/system/progress
import webql/engine/system/traverser/diagnostic
import webql/engine/system/traverser/traverse_batch

/// Runs an executable plan.
pub fn traverse(
  plan: plan.Plan,
  memory: memory.Memory(a, b),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let plan.Plan(routes:, batches:) = plan

  let progress = progress.add_parameters(memory, parameters)
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
  memory: memory.Memory(a, b),
) {
  case batches {
    [plan.Batch(batch:), ..batches] -> {
      use memory <- result.try(traverse_batch.traverse(
        batch,
        routes,
        memory,
        traverse,
      ))

      traverse_batches(batches, routes, memory)
    }

    [] -> Ok(memory)
  }
}
