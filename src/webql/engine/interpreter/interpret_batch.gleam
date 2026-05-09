import gleam/list
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_step
import webql/engine/interpreter/memory
import webql/engine/interpreter/runtime
import webql/resolution

/// Runs the next batch in a plan.
pub fn interpret(
  batch: List(plan.Step),
  routes: List(plan.Route),
  runtime: runtime.Runtime(memory.Memory(storage), diagnostic.Diagnostic),
  memory: memory.Memory(storage),
  interpret_plan,
) -> resolution.Resolution(memory.Memory(storage), diagnostic.Diagnostic) {
  let steps =
    list.map(batch, fn(step) {
      interpret_step.interpret(step, routes, runtime, memory, interpret_plan)
    })

  runtime.steps(memory, steps, memory.merge)
}
