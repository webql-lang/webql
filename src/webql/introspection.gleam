import gleam/dict
import gleam/list
import webql/document

pub type Schema {
  Schema(operators: List(Operator), typenames: List(String))
}

pub type Operator {
  Operator(name: String, inputs: List(Input), outputs: List(Output))
}

pub type Input {
  Input(name: String, typename: String)
}

pub type Output {
  Output(name: String, typename: String)
}

/// Builds the public schema exposed by a document.
pub fn introspect(document: document.Document) -> Schema {
  let document.Document(operators:, typenames:) = document

  let operators = introspect_operators(operators)
  let typenames = introspect_typenames(typenames)

  Schema(operators:, typenames:)
}

// PRIVATE FUNCTIONS
// =================
fn introspect_typenames(typenames: List(document.Typename)) {
  list.map(typenames, fn(typename) { typename.name })
}

fn introspect_operators(operators: dict.Dict(String, document.Operator)) {
  operators
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(name, operator) = entry
    introspect_operator(name, operator)
  })
}

fn introspect_operator(name: String, operator: document.Operator) {
  let document.Operator(inputs:, outputs:, ..) = operator

  Operator(
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
    Input(name:, typename:)
  })
}

fn introspect_outputs(outputs: dict.Dict(String, document.Output)) {
  outputs
  |> dict.values()
  |> list.map(fn(output) {
    let document.Output(name:, typename:) = output
    Output(name:, typename:)
  })
}
