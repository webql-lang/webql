import gleam/dict
import webql/compiler/environment
import webql/compiler/reference

pub fn add_node_assigns_stable_reference_test() {
  let environment =
    environment.add_nodes(environment.new(), [
      "Math",
      "Text",
      "Math",
    ])

  let environment.Environment(nodes:, ..) = environment

  assert nodes
    == dict.new()
    |> dict.insert("Math", reference.Node(0))
    |> dict.insert("Text", reference.Node(1))
}

pub fn add_input_registers_node_port_test() {
  let environment =
    environment.add_inputs(environment.new(), reference.Node(2), [
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_inputs(environment, reference.Node(2))
    == Ok([
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn add_output_registers_node_port_test() {
  let environment =
    environment.add_outputs(environment.new(), reference.Node(3), [
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_outputs(environment, reference.Node(3))
    == Ok([
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn new_environment_registers_node_catalog_test() {
  let environment =
    environment.new()
    |> environment.add_node("Math")
    |> environment.add_port("Int")
    |> environment.add_input(reference.Node(0), #("l", reference.Port(0)))
    |> environment.add_output(reference.Node(0), #("value", reference.Port(0)))

  assert environment.get_node(environment, "Math") == Ok(reference.Node(0))
  assert environment.get_port(environment, "Int") == Ok(reference.Port(0))
  assert environment.get_inputs(environment, reference.Node(0))
    == Ok([#("l", reference.Port(0))])
  assert environment.get_outputs(environment, reference.Node(0))
    == Ok([#("value", reference.Port(0))])
}
