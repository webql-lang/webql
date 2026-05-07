import gleam/result
import webql/engine/system/plan
import webql/engine/system/progress
import webql/engine/system/traverser/traverse_step

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
