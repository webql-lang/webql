import gleam/list
import webql/engine/plan
import webql/engine/runner/progress

/// Registers executable routes into progress.
pub fn propagate(progress: progress.Progress, routes: List(plan.Route)) {
  list.fold(routes, progress, fn(progress, route) {
    case route {
      plan.Route(from:, to:) -> propagate_route(progress, from, to)
      plan.Constant(value:, to:) -> progress.add_value(progress, to, value)
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn propagate_route(
  progress: progress.Progress,
  from: List(String),
  to: List(String),
) {
  case progress.get_value(progress, from) {
    Ok(value) -> progress.add_value(progress, to, value)
    Error(_nil) -> progress
  }
}
