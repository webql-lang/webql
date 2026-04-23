import gleam/dict
import webql/compiler/resolver/reference
import webql/compiler/resolver/schema

pub fn add_typename_assigns_stable_reference_test() {
  let schema = schema.add_typenames(schema.new(), ["Int", "String", "Int"])

  let schema.Schema(typenames:, ..) = schema

  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
    ])
}

pub fn add_node_assigns_stable_reference_test() {
  let schema = schema.add_nodes(schema.new(), ["Math", "Text", "Math"])

  let schema.Schema(nodes:, ..) = schema

  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Text", reference.Node(1)),
    ])
}

pub fn add_input_registers_typed_node_inputs_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_input(reference.Node(0), #("l", reference.Typename(0)))
    |> schema.add_input(reference.Node(0), #("r", reference.Typename(0)))

  let schema.Schema(inputs:, ..) = schema

  assert inputs
    == dict.from_list([
      #(reference.Node(0), [
        #("l", reference.Typename(0)),
        #("r", reference.Typename(0)),
      ]),
    ])
}

pub fn add_output_registers_typed_node_outputs_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_output(reference.Node(0), #("value", reference.Typename(0)))

  let schema.Schema(outputs:, ..) = schema

  assert outputs
    == dict.from_list([
      #(reference.Node(0), [#("value", reference.Typename(0))]),
    ])
}

pub fn add_inputs_registers_multiple_typed_node_inputs_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_inputs(reference.Node(0), [
      #("l", reference.Typename(0)),
      #("r", reference.Typename(0)),
    ])

  let schema.Schema(inputs:, ..) = schema

  assert inputs
    == dict.from_list([
      #(reference.Node(0), [
        #("l", reference.Typename(0)),
        #("r", reference.Typename(0)),
      ]),
    ])
}

pub fn add_outputs_registers_multiple_typed_node_outputs_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_outputs(reference.Node(0), [
      #("value", reference.Typename(0)),
      #("count", reference.Typename(0)),
    ])

  let schema.Schema(outputs:, ..) = schema

  assert outputs
    == dict.from_list([
      #(reference.Node(0), [
        #("value", reference.Typename(0)),
        #("count", reference.Typename(0)),
      ]),
    ])
}

pub fn get_typename_returns_registered_reference_test() {
  let schema = schema.add_typename(schema.new(), "Int")

  assert schema.get_typename(schema, "Int") == Ok(reference.Typename(0))
}

pub fn get_node_returns_registered_reference_test() {
  let schema = schema.add_node(schema.new(), "Math")

  assert schema.get_node(schema, "Math") == Ok(reference.Node(0))
}

pub fn get_inputs_returns_registered_ports_test() {
  let schema =
    schema.new()
    |> schema.add_input(reference.Node(0), #("l", reference.Typename(0)))

  assert schema.get_inputs(schema, reference.Node(0))
    == Ok([#("l", reference.Typename(0))])
}

pub fn get_outputs_returns_registered_ports_test() {
  let schema =
    schema.new()
    |> schema.add_output(reference.Node(0), #("value", reference.Typename(0)))

  assert schema.get_outputs(schema, reference.Node(0))
    == Ok([#("value", reference.Typename(0))])
}
