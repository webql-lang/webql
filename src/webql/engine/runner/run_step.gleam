import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress

/// Runs a step in a batch.
pub fn run(
  step: plan.Step,
  routes: List(plan.Route),
  progress: progress.Progress,
  run_plan,
) {
  case progress.get_inputs(progress, step.name, routes) {
    Ok(inputs) -> run_step(step, inputs, progress, run_plan)
    Error(_nil) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(step: step.name)),
      )
  }
}

// PRIVATE FUNCTIONS
// =================
fn run_step(
  step: plan.Step,
  inputs: dict.Dict(String, dynamic.Dynamic),
  progress: progress.Progress,
  run_plan,
) {
  let plan.Step(name:, resolver:) = step

  case resolver {
    plan.FunctionResolver(function:) ->
      run_resolver(name, function, inputs, progress)

    plan.InlineResolver(plan:) -> {
      use outputs <- result.try(run_plan(plan, inputs))
      Ok(progress.add_outputs(progress, name, outputs))
    }
  }
}

fn run_resolver(
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
