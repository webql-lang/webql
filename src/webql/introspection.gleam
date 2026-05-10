import gleam/dict
import gleam/list
import webql/document

pub type Schema {
  Schema(operators: List(Operator), typenames: List(String))
}

pub type Operator {
  Operator(name: String, parameters: List(Parameter), returns: List(Return))
}

pub type Parameter {
  Parameter(name: String, typename: String)
}

pub type Return {
  Return(name: String, typename: String)
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
  let document.Operator(parameters:, returns:, ..) = operator

  Operator(
    name:,
    parameters: introspect_parameters(parameters),
    returns: introspect_returns(returns),
  )
}

fn introspect_parameters(parameters: dict.Dict(String, document.Parameter)) {
  parameters
  |> dict.values()
  |> list.map(fn(input) {
    let document.Parameter(name:, typename:) = input
    Parameter(name:, typename:)
  })
}

fn introspect_returns(returns: dict.Dict(String, document.Return)) {
  returns
  |> dict.values()
  |> list.map(fn(output) {
    let document.Return(name:, typename:) = output
    Return(name:, typename:)
  })
}
