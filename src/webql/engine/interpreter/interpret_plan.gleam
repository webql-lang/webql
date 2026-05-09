import gleam/dict
import gleam/dynamic
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_batch
import webql/engine/interpreter/memory
import webql/engine/interpreter/progress
import webql/engine/interpreter/runtime
import webql/resolution

/// Runs an executable plan.
pub fn interpret(
  plan: plan.Plan,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    plan.Batch,
    diagnostic.Diagnostic,
  ),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> resolution.Resolution(dynamic.Dynamic, diagnostic.Diagnostic) {
  let memory = interpret_plan(plan, memory, runtime, parameters)

  runtime.complete(memory, fn(memory) {
    case progress.get_returns(memory, plan.routes) {
      Ok(returns) -> Ok(progress.encode(returns))

      Error(message) ->
        Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
    }
  })
}

// PRIVATE FUNCTIONS
// =================
fn interpret_plan(
  plan: plan.Plan,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    plan.Batch,
    diagnostic.Diagnostic,
  ),
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  let plan.Plan(routes:, batches:) = plan

  memory
  |> progress.add_parameters(parameters)
  |> runtime.batches(batches, fn(memory, batch) {
    let plan.Batch(batch:) = batch
    interpret_batch.interpret(batch, routes, runtime, memory, interpret_plan)
  })
}
