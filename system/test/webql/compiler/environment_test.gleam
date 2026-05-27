import gleam/dict
import webql/compiler/environment
import webql/compiler/reference

pub fn add_operation_assigns_stable_reference_test() {
  let environment =
    environment.add_operations(environment.new(), [
      "Math",
      "Text",
      "Math",
    ])

  let environment.Environment(operations:, ..) = environment

  assert operations
    == dict.from_list([
      #("Math", reference.Operation(0)),
      #("Text", reference.Operation(1)),
    ])
}

pub fn add_input_registers_operation_port_test() {
  let environment =
    environment.add_inputs(environment.new(), reference.Operation(2), [
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_inputs(environment, reference.Operation(2))
    == Ok([
      #("in", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn add_output_registers_operation_port_test() {
  let environment =
    environment.add_outputs(environment.new(), reference.Operation(3), [
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])

  assert environment.get_outputs(environment, reference.Operation(3))
    == Ok([
      #("out", reference.Port(0)),
      #("value", reference.Port(1)),
    ])
}

pub fn new_environment_registers_operation_catalog_test() {
  let environment =
    environment.new()
    |> environment.add_operation("Math")
    |> environment.add_port("Int")
    |> environment.add_input(reference.Operation(0), #("l", reference.Port(0)))
    |> environment.add_output(reference.Operation(0), #(
      "value",
      reference.Port(0),
    ))

  assert environment.get_operation(environment, "Math")
    == Ok(reference.Operation(0))
  assert environment.get_port(environment, "Int") == Ok(reference.Port(0))
  assert environment.get_inputs(environment, reference.Operation(0))
    == Ok([#("l", reference.Port(0))])
  assert environment.get_outputs(environment, reference.Operation(0))
    == Ok([#("value", reference.Port(0))])
}
