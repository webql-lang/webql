import gleam/dict
import webql/lang/compiler/environment
import webql/lang/compiler/reference
import webql/lang/loader/schema

pub fn add_node_assigns_stable_reference_test() {
  let environment =
    environment.add_nodes(environment.new(schema.new()), [
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
    environment.add_inputs(environment.new(schema.new()), reference.Node(2), [
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
    environment.add_outputs(environment.new(schema.new()), reference.Node(3), [
      #("out", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])

  assert environment.get_outputs(environment, reference.Node(3))
    == Ok([
      #("out", reference.Typename(0)),
      #("value", reference.Typename(1)),
    ])
}

pub fn new_copies_node_catalog_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_input(reference.Node(0), #("l", reference.Typename(0)))
    |> schema.add_output(reference.Node(0), #("value", reference.Typename(0)))

  let environment = environment.new(schema)

  assert environment.get_node(environment, "Math") == Ok(reference.Node(0))
  assert environment.get_inputs(environment, reference.Node(0))
    == Ok([#("l", reference.Typename(0))])
  assert environment.get_outputs(environment, reference.Node(0))
    == Ok([#("value", reference.Typename(0))])
}
