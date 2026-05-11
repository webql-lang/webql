import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result
import webql/assembler/plan
import webql/interpreter/diagnostic
import webql/memory

/// Stores initial plan parameters as root-level values.
pub fn add_parameters(
  memory: memory.Memory(storage),
  parameters: dynamic.Dynamic,
) -> Result(memory.Memory(storage), diagnostic.Diagnostic) {
  case decode(parameters) {
    Ok(parameters) -> {
      let memory =
        dict.fold(parameters, memory, fn(memory, name, value) {
          memory.set(memory, [name], value)
        })

      Ok(memory)
    }

    Error(errors) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.InvalidParameters(errors:)))
  }
}

/// Stores outputs produced by a completed step.
pub fn add_outputs(
  memory: memory.Memory(storage),
  step: String,
  outputs: dynamic.Dynamic,
) -> Result(memory.Memory(storage), diagnostic.Diagnostic) {
  case decode(outputs) {
    Ok(outputs) -> {
      let memory =
        dict.fold(outputs, memory, fn(memory, name, value) {
          memory.set(memory, [step, name], value)
        })

      Ok(memory)
    }

    Error(errors) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.InvalidStepOutput(step:, errors:)),
      )
  }
}

/// Resolves all input values for a step by following routes that target it.
pub fn get_inputs(
  memory: memory.Memory(storage),
  step: String,
  routes: List(plan.Route),
) -> Result(dynamic.Dynamic, diagnostic.Diagnostic) {
  let inputs = dict.new()
  let results =
    list.try_fold(routes, inputs, fn(inputs, route) {
      case route {
        plan.Route(from:, to: [target, input]) if target == step -> {
          use value <- result.try(memory.get(memory, from))
          Ok(dict.insert(inputs, input, value))
        }

        plan.Constant(value:, to: [target, input]) if target == step ->
          Ok(dict.insert(inputs, input, value))

        _route -> Ok(inputs)
      }
    })

  case results {
    Ok(results) -> Ok(encode(results))
    Error(message) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(step:, message:)),
      )
  }
}

/// Resolves final return values from root-level values.
pub fn get_returns(
  memory: memory.Memory(storage),
  routes: List(plan.Route),
) -> Result(dynamic.Dynamic, dynamic.Dynamic) {
  use returns <- result.try(
    list.try_fold(routes, dict.new(), fn(returns, route) {
      case route {
        plan.Route(from:, to: [output]) -> {
          use value <- result.try(memory.get(memory, from))
          Ok(dict.insert(returns, output, value))
        }

        plan.Constant(value:, to: [output]) ->
          Ok(dict.insert(returns, output, value))

        _route -> Ok(returns)
      }
    }),
  )

  Ok(encode(returns))
}

// PRIVATE FUNCTIONS
// =================
fn encode(values: dict.Dict(String, dynamic.Dynamic)) -> dynamic.Dynamic {
  values
  |> dict.to_list()
  |> list.map(fn(input) {
    let #(key, value) = input
    #(dynamic.string(key), value)
  })
  |> dynamic.properties()
}

fn decode(
  unknown: dynamic.Dynamic,
) -> Result(dict.Dict(String, dynamic.Dynamic), List(decode.DecodeError)) {
  let schema = decode.dict(decode.string, decode.dynamic)
  case decode.run(unknown, schema) {
    Ok(result) -> Ok(result)
    Error(errors) -> Error(errors)
  }
}
