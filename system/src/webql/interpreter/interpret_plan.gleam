import gleam/dynamic
import gleam/list
import gleam/result
import webql/assembler/plan
import webql/engine
import webql/interpreter/diagnostic
import webql/interpreter/interpret_batch
import webql/interpreter/progress
import webql/memory

/// Runs an executable plan.
pub fn interpret(
  plan: plan.Plan(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) -> task {
  let result = interpret_plan(plan, memory, engine, parameters)

  engine.finish_plan(result, fn(memory) {
    case progress.get_returns(memory, plan.edges) {
      Ok(returns) -> Ok(returns)

      Error(message) ->
        Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn interpret_plan(
  plan: plan.Plan(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), error),
  parameters: dynamic.Dynamic,
) {
  let plan.Plan(edges:, batches:) = plan

  engine.start_plan(fn() {
    use memory <- result.try(progress.add_parameters(memory, parameters))

    Ok(#(
      memory,
      list.map(batches, fn(batch) {
        fn(memory) {
          let plan.Batch(steps:) = batch
          interpret_batch.interpret(
            steps,
            edges,
            engine,
            memory,
            interpret_plan,
          )
        }
      }),
    ))
  })
}
