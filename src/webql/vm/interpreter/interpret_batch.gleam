import gleam/result
import webql/vm/assembler/plan
import webql/vm/interpreter/interpret_step
import webql/vm/interpreter/memory

/// Runs the next batch in a plan.
pub fn interpret(
  batch: List(plan.Step),
  routes: List(plan.Route),
  memory: memory.Memory(a, b),
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
