import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/result
import webql/runtime/engine/plan

pub type Progress {
  Progress(values: dict.Dict(List(String), dynamic.Dynamic))
}

/// Creates new progress for a plan execution.
pub fn new() -> Progress {
  Progress(values: dict.new())
}

/// Stores initial plan parameters as root-level values.
pub fn add_parameters(
  progress: Progress,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Progress {
  use progress, name, value <- dict.fold(parameters, progress)
  Progress(values: dict.insert(progress.values, [name], value))
}

/// Stores outputs produced by a completed step.
pub fn add_outputs(
  progress: Progress,
  step: String,
  outputs: dict.Dict(String, dynamic.Dynamic),
) -> Progress {
  use progress, name, value <- dict.fold(outputs, progress)
  Progress(values: dict.insert(progress.values, [step, name], value))
}

/// Resolves all input values for a step by following routes that target it.
pub fn get_inputs(
  progress: Progress,
  step: String,
  routes: List(plan.Route),
) -> Result(dict.Dict(String, dynamic.Dynamic), Nil) {
  use inputs, route <- list.try_fold(routes, dict.new())

  case route {
    plan.Route(from:, to: [target, input]) if target == step -> {
      use value <- result.try(get_outlet(progress, from))
      Ok(dict.insert(inputs, input, value))
    }

    plan.Constant(value:, to: [target, input]) if target == step ->
      Ok(dict.insert(inputs, input, value))

    _route -> Ok(inputs)
  }
}

/// Resolves final return values from root-level values.
pub fn get_returns(
  progress: Progress,
  routes: List(plan.Route),
) -> Result(dict.Dict(String, dynamic.Dynamic), Nil) {
  use returns, route <- list.try_fold(routes, dict.new())

  case route {
    plan.Route(from:, to: [output]) -> {
      use value <- result.try(get_outlet(progress, from))
      Ok(dict.insert(returns, output, value))
    }

    plan.Constant(value:, to: [output]) ->
      Ok(dict.insert(returns, output, value))

    _route -> Ok(returns)
  }
}

// PRIVATE FUNCTIONS
// =================
fn get_outlet(
  progress: Progress,
  path: List(String),
) -> Result(dynamic.Dynamic, Nil) {
  dict.get(progress.values, path)
}
