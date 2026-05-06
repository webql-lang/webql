import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/runtime/engine/plan
import webql/runtime/engine/traverser/diagnostic
import webql/runtime/engine/traverser/progress

/// Runs a step in a batch.
pub fn traverse(
  step: plan.Step,
  routes: List(plan.Route),
  progress: progress.Progress,
  traverse_plan,
) {
  case progress.get_inputs(progress, step.name, routes) {
    Ok(inputs) -> traverse_step(step, inputs, progress, traverse_plan)
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
  progress: progress.Progress,
  traverse_plan,
) {
  let plan.Step(name:, resolver:) = step

  case resolver {
    plan.FunctionResolver(function:) ->
      traverse_resolver(name, function, inputs, progress)

    plan.InlineResolver(plan:) -> {
      use outputs <- result.try(traverse_plan(plan, inputs))
      Ok(progress.add_outputs(progress, name, outputs))
    }
  }
}

fn traverse_resolver(
  step: String,
  function: document.Resolver,
  inputs: dict.Dict(String, dynamic.Dynamic),
  progress: progress.Progress,
) {
  let document.Resolver(resolver:) = function

  case resolver(inputs) {
    Ok(outputs) -> Ok(progress.add_outputs(progress, step, outputs))
    Error(message) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RuntimeError(step:, message:)),
      )
  }
}
