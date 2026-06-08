import gleam/dynamic
import gleam/list
import gleam/result
import webql/assembler/plan
import webql/engine
import webql/memory
import webql/runner/diagnostic
import webql/runner/run
import webql/runner/run_batch

/// Runs an executable plan.
pub fn run(
  plan: plan.Plan(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) -> task {
  let result = run_plan(plan, memory, engine, parameters)

  engine.handle_finish_plan(result, fn(memory) {
    case run.get_returns(memory, plan.edges) {
      Ok(returns) -> Ok(returns)

      Error(message) ->
        Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn run_plan(
  plan: plan.Plan(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) {
  let plan.Plan(edges:, batches:) = plan

  engine.handle_start_plan(fn() {
    use memory <- result.try(run.add_parameters(memory, parameters))

    Ok(#(
      memory,
      list.map(batches, fn(batch) {
        fn(memory) {
          let plan.Batch(steps:) = batch
          run_batch.run(steps, edges, engine, memory, run_plan)
        }
      }),
    ))
  })
}
