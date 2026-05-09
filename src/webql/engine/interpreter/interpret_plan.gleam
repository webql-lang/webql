import gleam/dict
import gleam/dynamic
import gleam/result
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_batch
import webql/engine/interpreter/memory
import webql/engine/interpreter/progress

/// Runs an executable plan.
pub fn interpret(
  plan: plan.Plan,
  memory: memory.Memory(storage),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let plan.Plan(routes:, batches:) = plan

  let progress = progress.add_parameters(memory, parameters)
  use progress <- result.try(interpret_batches(batches, routes, progress))

  case progress.get_returns(progress, plan.routes) {
    Ok(returns) -> Ok(returns)
    Error(message) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(message:)))
  }
}

// PRIVATE FUNCTIONS
// =================
fn interpret_batches(
  batches: List(plan.Batch),
  routes: List(plan.Route),
  memory: memory.Memory(storage),
) {
  case batches {
    [plan.Batch(batch:), ..batches] -> {
      use memory <- result.try(interpret_batch.interpret(
        batch,
        routes,
        memory,
        interpret,
      ))

      interpret_batches(batches, routes, memory)
    }

    [] -> Ok(memory)
  }
}
