import gleam/result
import webql/engine/plan
import webql/engine/runner/progress
import webql/engine/runner/run_step

/// Runs the next batch in a plan.
pub fn run(
  batch: List(plan.Step),
  routes: List(plan.Route),
  progress: progress.Progress,
  run_plan,
) {
  case batch {
    [step, ..batch] -> {
      use progress <- result.try(run_step.run(step, routes, progress, run_plan))
      run(batch, routes, progress, run_plan)
    }

    [] -> Ok(progress)
  }
}
