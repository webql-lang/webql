import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/result
import webql/engine/assembler/plan
import webql/engine/interpreter/memory

/// Stores initial plan parameters as root-level values.
pub fn add_parameters(
  memory: memory.Memory(a, b),
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> memory.Memory(a, b) {
  use memory, name, value <- dict.fold(parameters, memory)
  memory.set(memory, [name], value)
}

/// Stores outputs produced by a completed step.
pub fn add_outputs(
  memory: memory.Memory(a, b),
  step: String,
  outputs: dict.Dict(String, dynamic.Dynamic),
) -> memory.Memory(a, b) {
  use memory, name, value <- dict.fold(outputs, memory)
  memory.set(memory, [step, name], value)
}

/// Resolves all input values for a step by following routes that target it.
pub fn get_inputs(
  memory: memory.Memory(a, b),
  step: String,
  routes: List(plan.Route),
) -> Result(dict.Dict(String, dynamic.Dynamic), b) {
  use inputs, route <- list.try_fold(routes, dict.new())

  case route {
    plan.Route(from:, to: [target, input]) if target == step -> {
      use value <- result.try(memory.get(memory, from))
      Ok(dict.insert(inputs, input, value))
    }

    plan.Constant(value:, to: [target, input]) if target == step ->
      Ok(dict.insert(inputs, input, value))

    _route -> Ok(inputs)
  }
}

/// Resolves final return values from root-level values.
pub fn get_returns(
  memory: memory.Memory(a, b),
  routes: List(plan.Route),
) -> Result(dict.Dict(String, dynamic.Dynamic), b) {
  use returns, route <- list.try_fold(routes, dict.new())

  case route {
    plan.Route(from:, to: [output]) -> {
      use value <- result.try(memory.get(memory, from))
      Ok(dict.insert(returns, output, value))
    }

    plan.Constant(value:, to: [output]) ->
      Ok(dict.insert(returns, output, value))

    _route -> Ok(returns)
  }
}
