import gleam/dict
import gleam/list
import webql/document
import webql/introspection/schema

/// Builds the public schema exposed by a document.
pub fn introspect(document: document.Document) -> schema.Schema {
  let document.Document(operators:) = document
  schema.Schema(operators: dict.map_values(operators, introspect_operator))
}

// PRIVATE FUNCTIONS
// =================
fn introspect_operator(name: String, operator: document.Operator) {
  let document.Operator(inputs:, outputs:, ..) = operator

  schema.Operator(
    name:,
    inputs: introspect_inputs(inputs),
    outputs: introspect_outputs(outputs),
  )
}

fn introspect_inputs(inputs: dict.Dict(String, document.Input)) {
  inputs
  |> dict.values()
  |> list.map(fn(input) {
    let document.Input(name:, typename:) = input
    schema.Input(name:, typename:)
  })
}

fn introspect_outputs(outputs: dict.Dict(String, document.Output)) {
  outputs
  |> dict.values()
  |> list.map(fn(output) {
    let document.Output(name:, typename:) = output
    schema.Output(name:, typename:)
  })
}
