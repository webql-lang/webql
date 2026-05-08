import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/memory
import webql/engine/system/plan
import webql/engine/system/progress
import webql/engine/system/traverser/diagnostic

/// Runs a step in a batch.
pub fn traverse(
  step: plan.Step,
  routes: List(plan.Route),
  memory: memory.Memory(a, b),
  traverse_plan,
) {
  case progress.get_inputs(memory, step.name, routes) {
    Ok(inputs) -> traverse_step(step, inputs, memory, traverse_plan)
    Error(_nil) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(step: step.name)),
      )
  }
}

// PRIVATE FUNCTIONS
// =================
fn traverse_step(
  step: plan.Step,
  inputs: dict.Dict(String, dynamic.Dynamic),
  memory: memory.Memory(a, b),
  traverse_plan,
) {
  let plan.Step(name:, resolver:) = step

  case resolver {
    plan.FunctionResolver(function:) ->
      traverse_resolver(name, function, inputs, memory)

    plan.InlineResolver(plan:) -> {
      use outputs <- result.try(traverse_plan(plan, memory.new(), inputs))
      Ok(progress.add_outputs(memory, name, outputs))
    }
  }
}

fn traverse_resolver(
  step: String,
  function: document.Resolver,
  inputs: dict.Dict(String, dynamic.Dynamic),
  memory: memory.Memory(a, b),
) {
  let document.Resolver(resolver:) = function

  case resolver(inputs) {
    Ok(outputs) -> Ok(progress.add_outputs(memory, step, outputs))
    Error(message) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RuntimeError(step:, message:)),
      )
  }
}
