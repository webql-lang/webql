import gleam/dict
import webql/lang/resolver/reference
import webql/lang/resolver/registry

pub fn add_typename_assigns_stable_reference_test() {
  let registry =
    registry.add_typenames(registry.new(), ["Int", "String", "Int"])

  let registry.Registry(typenames:, ..) = registry

  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
    ])
}

pub fn add_node_assigns_stable_reference_test() {
  let registry = registry.add_nodes(registry.new(), ["Math", "Text", "Math"])

  let registry.Registry(nodes:, ..) = registry

  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Text", reference.Node(1)),
    ])
}

pub fn add_input_assigns_stable_reference_test() {
  let registry =
    registry.add_inputs(registry.new(), [["in"], ["math", "in"], ["in"]])

  let registry.Registry(inputs:, ..) = registry

  assert inputs
    == dict.from_list([
      #(["in"], reference.Input(0)),
      #(["math", "in"], reference.Input(1)),
    ])
}

pub fn add_output_assigns_stable_reference_test() {
  let registry =
    registry.add_outputs(registry.new(), [["out"], ["math", "out"], ["out"]])

  let registry.Registry(outputs:, ..) = registry

  assert outputs
    == dict.from_list([
      #(["out"], reference.Output(0)),
      #(["math", "out"], reference.Output(1)),
    ])
}

pub fn add_binding_assigns_stable_reference_test() {
  let registry =
    registry.add_bindings(registry.new(), [["math"], ["text"], ["math"]])

  let registry.Registry(bindings:, ..) = registry

  assert bindings
    == dict.from_list([
      #(["math"], reference.Binding(0)),
      #(["text"], reference.Binding(1)),
    ])
}

pub fn add_operation_keeps_existing_registration_test() {
  let first_operation_registry = registry.add_typename(registry.new(), "Int")
  let second_operation_registry =
    registry.add_typename(registry.new(), "String")

  let registry =
    registry.add_operation(
      registry.add_operation(registry.new(), "Math", first_operation_registry),
      "Math",
      second_operation_registry,
    )

  let registry.Registry(operations:, ..) = registry

  assert operations
    == dict.from_list([
      #("Math", #(reference.Operation(0), first_operation_registry)),
    ])
}
