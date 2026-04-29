import gleam/dict
import webql/lang/compiler/environment
import webql/lang/compiler/reference

pub fn add_node_assigns_stable_reference_test() {
  let environment =
    environment.add_nodes(environment.new(), [
      "Math",
      "Text",
      "Math",
    ])

  let environment.Environment(nodes:, ..) = environment

  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Text", reference.Node(1)),
    ])
}

pub fn add_input_registers_node_port_test() {
  let environment =
    environment.add_inputs(environment.new(), reference.Node(2), [
      #("in", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])

  assert environment.get_inputs(environment, reference.Node(2))
    == Ok([
      #("in", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])
}

pub fn add_output_registers_node_port_test() {
  let environment =
    environment.add_outputs(environment.new(), reference.Node(3), [
      #("out", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])

  assert environment.get_outputs(environment, reference.Node(3))
    == Ok([
      #("out", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])
}

pub fn new_environment_registers_node_catalog_test() {
  let environment =
    environment.new()
    |> environment.add_node("Math")
    |> environment.add_typename("Int")
    |> environment.add_input(reference.Node(0), #("l", reference.Typename(0)))
    |> environment.add_output(reference.Node(0), #(
      "value",
      reference.Typename(0),
    ))

  assert environment.get_node(environment, "Math") == Ok(reference.Node(0))
  assert environment.get_typename(environment, "Int")
    == Ok(reference.Typename(0))
  assert environment.get_inputs(environment, reference.Node(0))
    == Ok([#("l", reference.Typename(0))])
  assert environment.get_outputs(environment, reference.Node(0))
    == Ok([#("value", reference.Typename(0))])
}
