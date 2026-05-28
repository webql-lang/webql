import gleam/dict
import gleam/list
import webql/schema

pub type Schema {
  Schema(operations: List(Operation), ports: List(String))
}

pub type Operation {
  Operation(name: String, inputs: List(Input), outputs: List(Output))
}

pub type Input {
  Input(name: String, port: String)
}

pub type Output {
  Output(name: String, port: String)
}

/// Builds the public schema exposed by a runtime schema.
pub fn introspect(schema: schema.Schema(task)) -> Schema {
  let schema.Schema(operations:, ports:) = schema

  let operations = introspect_operations(operations)
  let ports = introspect_ports(ports)

  Schema(operations:, ports:)
}

// PRIVATE FUNCTIONS
// =================
fn introspect_ports(ports: List(schema.Port)) {
  list.map(ports, fn(port) { port.name })
}

fn introspect_operations(
  operations: dict.Dict(String, schema.Operation(task)),
) {
  operations
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(name, operation) = entry
    introspect_operation(name, operation)
  })
}

fn introspect_operation(name: String, operation: schema.Operation(task)) {
  let schema.Operation(inputs:, outputs:, ..) = operation

  Operation(
    name:,
    inputs: introspect_parameters(inputs),
    outputs: introspect_returns(outputs),
  )
}

fn introspect_parameters(inputs: dict.Dict(String, schema.Input)) {
  inputs
  |> dict.values()
  |> list.map(fn(input) {
    let schema.Input(name:, port:) = input
    Input(name:, port:)
  })
}

fn introspect_returns(outputs: dict.Dict(String, schema.Output)) {
  outputs
  |> dict.values()
  |> list.map(fn(output) {
    let schema.Output(name:, port:) = output
    Output(name:, port:)
  })
}
