import gleam/dict
import webql/compiler/environment
import webql/compiler/reference

pub fn add_node_assigns_stable_kind_test() {
  let environment =
    environment.add_nodes(environment.new(), [
      "Math",
      "Text",
      "Math",
    ])

  let environment.Environment(nodes:, ..) = environment

  assert nodes
    == dict.from_list([
      #("Math", reference.Kind(0)),
      #("Text", reference.Kind(1)),
    ])
}

pub fn add_input_registers_node_port_test() {
  let environment =
    environment.add_inputs(environment.new(), reference.Kind(2), [
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_inputs(environment, reference.Kind(2))
    == Ok([
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn add_output_registers_node_port_test() {
  let environment =
    environment.add_outputs(environment.new(), reference.Kind(3), [
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_outputs(environment, reference.Kind(3))
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
    |> environment.add_input(reference.Kind(0), #("l", reference.Port(0)))
    |> environment.add_output(reference.Kind(0), #("value", reference.Port(0)))

  assert environment.get_node(environment, "Math") == Ok(reference.Kind(0))
  assert environment.get_port(environment, "Int") == Ok(reference.Port(0))
  assert environment.get_inputs(environment, reference.Kind(0))
    == Ok([#("l", reference.Port(0))])
  assert environment.get_outputs(environment, reference.Kind(0))
    == Ok([#("value", reference.Port(0))])
}
