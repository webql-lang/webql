import gleam/dict
import webql/compiler/environment
import webql/compiler/reference

pub fn add_node_registers_node_name_test() {
  let environment =
    environment.add_nodes(environment.new(), [
      "Math",
      "Text",
      "Math",
    ])

  let environment.Environment(nodes:, ..) = environment

  assert nodes
    == dict.new()
    |> dict.insert("Math", Nil)
    |> dict.insert("Text", Nil)
}

pub fn add_input_registers_node_port_test() {
  let environment =
    environment.add_inputs(environment.new(), "Math", [
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_inputs(environment, "Math")
    == Ok([
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn add_output_registers_node_port_test() {
  let environment =
    environment.add_outputs(environment.new(), "Math", [
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_outputs(environment, "Math")
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
    |> environment.add_input("Math", #("l", reference.Port(0)))
    |> environment.add_output("Math", #("value", reference.Port(0)))

  assert environment.get_node(environment, "Math") == Ok(Nil)
  assert environment.get_port(environment, "Int") == Ok(reference.Port(0))
  assert environment.get_inputs(environment, "Math")
    == Ok([#("l", reference.Port(0))])
  assert environment.get_outputs(environment, "Math")
    == Ok([#("value", reference.Port(0))])
}
