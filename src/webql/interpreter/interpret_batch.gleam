import gleam/list
import webql/assembler/plan
import webql/engine
import webql/interpreter/interpret_step
import webql/memory

/// Runs the next batch in a plan.
pub fn interpret(
  batch: List(plan.Step(task)),
  routes: List(plan.Route),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  interpret_plan,
) -> task {
  let steps =
    engine.start_batch(fn() {
      batch
      |> list.map(fn(step) {
        interpret_step.interpret(step, routes, engine, memory, interpret_plan)
      })
      |> Ok()
    })

  engine.finish_batch(memory, steps, memory.merge)
}
