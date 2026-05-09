import gleam/result
import webql/engine/assembler/plan
import webql/engine/interpreter/interpret_step
import webql/engine/interpreter/memory

/// Runs the next batch in a plan.
pub fn interpret(
  batch: List(plan.Step),
  routes: List(plan.Route),
  memory: memory.Memory(storage),
  interpret_plan,
) {
  case batch {
    [step, ..batch] -> {
      use progress <- result.try(interpret_step.interpret(
        step,
        routes,
        memory,
        interpret_plan,
      ))

      interpret(batch, routes, progress, interpret_plan)
    }

    [] -> Ok(memory)
  }
}
