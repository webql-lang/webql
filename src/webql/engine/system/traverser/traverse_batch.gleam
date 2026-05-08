import gleam/result
import webql/engine/memory
import webql/engine/system/plan
import webql/engine/system/traverser/traverse_step

/// Runs the next batch in a plan.
pub fn traverse(
  batch: List(plan.Step),
  routes: List(plan.Route),
  memory: memory.Memory(a, b),
  traverse_plan,
) {
  case batch {
    [step, ..batch] -> {
      use progress <- result.try(traverse_step.traverse(
        step,
        routes,
        memory,
        traverse_plan,
      ))
      traverse(batch, routes, progress, traverse_plan)
    }

    [] -> Ok(memory)
  }
}
