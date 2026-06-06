import gleam/list
import webql/assembler/plan
import webql/engine
import webql/memory
import webql/runner/run_step

/// Runs the next batch in a plan.
pub fn run(
  batch: List(plan.Step(task)),
  edges: List(plan.Edge),
  engine: engine.Engine(task, memory.Memory(storage), error),
  memory: memory.Memory(storage),
  run_plan,
) -> task {
  let steps =
    engine.handle_start_batch(fn() {
      Ok(
        list.map(batch, fn(step) {
          run_step.run(step, edges, engine, memory, run_plan)
        }),
      )
    })

  engine.handle_finish_batch(memory, steps, memory.merge)
}
