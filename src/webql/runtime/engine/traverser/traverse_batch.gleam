import gleam/result
import webql/runtime/engine/plan
import webql/runtime/engine/traverser/progress
import webql/runtime/engine/traverser/traverse_step

/// Runs the next batch in a plan.
pub fn traverse(
  batch: List(plan.Step),
  routes: List(plan.Route),
  progress: progress.Progress,
  traverse_plan,
) {
  case batch {
    [step, ..batch] -> {
      use progress <- result.try(traverse_step.traverse(
        step,
        routes,
        progress,
        traverse_plan,
      ))
      traverse(batch, routes, progress, traverse_plan)
    }

    [] -> Ok(progress)
  }
}
