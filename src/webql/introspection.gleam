import gleam/dict
import gleam/list
import webql/schema

pub type Schema {
  Schema(nodes: List(Node), ports: List(String))
}

pub type Node {
  Node(name: String, inputs: List(Input), outputs: List(Output))
}

pub type Input {
  Input(name: String, port: String)
}

pub type Output {
  Output(name: String, port: String)
}

/// Builds the compiler introspection schema from a WebQL schema.
pub fn introspect(schema: schema.Schema) -> Schema {
  let schema.Schema(nodes:, ports:) = schema

  let nodes = introspect_nodes(nodes)
  let ports = introspect_ports(ports)

  Schema(nodes:, ports:)
}

// PRIVATE FUNCTIONS
// =================
fn introspect_ports(ports: List(schema.Port)) {
  list.map(ports, fn(port) { port.name })
}

fn introspect_nodes(nodes: dict.Dict(String, schema.Node)) {
  nodes
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(name, node) = entry
    introspect_node(name, node)
  })
}

fn introspect_node(name: String, node: schema.Node) {
  let schema.Node(inputs:, outputs:) = node

  Node(
    name:,
    inputs: introspect_inputs(inputs),
    outputs: introspect_outputs(outputs),
  )
}

fn introspect_inputs(inputs: dict.Dict(String, schema.Input)) {
  inputs
  |> dict.values()
  |> list.map(fn(input) {
    let schema.Input(name:, port:) = input
    Input(name:, port:)
  })
}

fn introspect_outputs(outputs: dict.Dict(String, schema.Output)) {
  outputs
  |> dict.values()
  |> list.map(fn(output) {
    let schema.Output(name:, port:) = output
    Output(name:, port:)
  })
}
