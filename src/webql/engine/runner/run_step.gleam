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
  let plan.Step(name:, resolver:) = step
  let inputs = dict.new()

  use inputs <- result.try(resolve_inputs(name, inputs, routes, progress))

  case resolver {
    plan.FunctionResolver(function:) ->
      run_function(name, function, inputs, progress)

    plan.InlineResolver(plan:) -> {
      use outputs <- result.try(run_plan(plan, inputs))
      Ok(progress.add_values(progress, [name], outputs))
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn run_function(
  name: String,
  function: document.Resolver,
  inputs: dict.Dict(String, dynamic.Dynamic),
  progress: progress.Progress,
) {
  case function.resolver(inputs) {
    Ok(outputs) -> Ok(progress.add_values(progress, [name], outputs))

    Error(message) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
          step: name,
          message:,
        )),
      )
  }
}

fn resolve_inputs(
  step: String,
  inputs: dict.Dict(String, dynamic.Dynamic),
  routes: List(plan.Route),
  progress: progress.Progress,
) {
  case routes {
    [route, ..routes] -> {
      resolve_input(route, routes, inputs, step, progress)
    }

    [] -> Ok(inputs)
  }
}

fn resolve_input(
  route: plan.Route,
  routes: List(plan.Route),
  inputs: dict.Dict(String, dynamic.Dynamic),
  step: String,
  progress: progress.Progress,
) {
  case route.to {
    [target_step, input] if target_step == step -> {
      resolve_input_to(input, step, routes, inputs, progress)
    }

    _target -> resolve_inputs(step, inputs, routes, progress)
  }
}

fn resolve_input_to(
  input: String,
  step: String,
  routes: List(plan.Route),
  inputs: dict.Dict(String, dynamic.Dynamic),
  progress: progress.Progress,
) {
  case progress.get_value(progress, [step, input]) {
    Ok(value) ->
      resolve_inputs(step, dict.insert(inputs, input, value), routes, progress)

    Error(_nil) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(step:, input:)),
      )
  }
}
