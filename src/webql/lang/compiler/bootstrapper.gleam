import gleam/dict
import gleam/list
import webql/lang/compiler/environment
import webql/system/introspection/schema

/// Bootstraps a compiler environment from a WebQL schema.
pub fn bootstrap(schema: schema.Schema) -> environment.Environment {
  let schema.Schema(operators:) = schema

  operators
  |> dict.values()
  |> list.fold(environment.new(), bootstrap_operator)
}

// PRIVATE FUNCTIONS
// =================
fn bootstrap_operator(
  environment: environment.Environment,
  operator: schema.Operator,
) -> environment.Environment {
  let schema.Operator(name:, inputs:, outputs:) = operator

  environment
  |> environment.add_node(name)
  |> bootstrap_inputs(name, inputs)
  |> bootstrap_outputs(name, outputs)
}

fn bootstrap_inputs(
  environment: environment.Environment,
  operator: String,
  inputs: List(schema.Input),
) -> environment.Environment {
  use environment, input <- list.fold(inputs, environment)
  let schema.Input(name:, typename:) = input

  let environment = environment.add_typename(environment, typename)
  let node = environment.get_node(environment, operator)
  let typename = environment.get_typename(environment, typename)

  case node, typename {
    Ok(node), Ok(typename) ->
      environment.add_input(environment, node, #(name, typename))

    _, _ -> environment
  }
}

fn bootstrap_outputs(
  environment: environment.Environment,
  operator: String,
  outputs: List(schema.Output),
) -> environment.Environment {
  use environment, output <- list.fold(outputs, environment)
  let schema.Output(name:, typename:) = output

  let environment = environment.add_typename(environment, typename)
  let node = environment.get_node(environment, operator)
  let typename = environment.get_typename(environment, typename)

  case node, typename {
    Ok(node), Ok(typename) ->
      environment.add_output(environment, node, #(name, typename))

    _, _ -> environment
  }
}
