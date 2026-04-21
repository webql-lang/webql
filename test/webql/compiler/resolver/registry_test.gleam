import gleam/dict
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry

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

pub fn add_parameter_assigns_stable_reference_test() {
  let registry =
    registry.add_parameters(registry.new(), [["in"], ["math", "in"], ["in"]])

  let registry.Registry(parameters:, ..) = registry

  assert parameters
    == dict.from_list([
      #(["in"], reference.Parameter(0)),
      #(["math", "in"], reference.Parameter(1)),
    ])
}

pub fn add_return_assigns_stable_reference_test() {
  let registry =
    registry.add_returns(registry.new(), [["out"], ["math", "out"], ["out"]])

  let registry.Registry(returns:, ..) = registry

  assert returns
    == dict.from_list([
      #(["out"], reference.Return(0)),
      #(["math", "out"], reference.Return(1)),
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
  let registry = registry.add_bindings(registry.new(), ["math", "text", "math"])

  let registry.Registry(bindings:, ..) = registry

  assert bindings
    == dict.from_list([
      #("math", reference.Binding(0)),
      #("text", reference.Binding(1)),
    ])
}

pub fn add_edge_assigns_stable_reference_test() {
  let registry =
    registry.new()
    |> registry.add_outputs([["math", "out"], ["value"]])
    |> registry.add_inputs([["out"], ["text", "in"]])
    |> registry.add_edges([
      reference.Input(0),
      reference.Input(1),
      reference.Input(0),
    ])

  let registry.Registry(edges:, ..) = registry

  assert edges
    == dict.from_list([
      #(reference.Input(0), reference.Edge(0)),
      #(reference.Input(1), reference.Edge(1)),
    ])
}

pub fn add_definition_keeps_existing_registration_test() {
  let first_definition_registry = registry.add_typename(registry.new(), "Int")
  let second_definition_registry =
    registry.add_typename(registry.new(), "String")

  let registry =
    registry.add_definition(
      registry.add_definition(registry.new(), "Math", first_definition_registry),
      "Math",
      second_definition_registry,
    )

  let registry.Registry(definitions:, ..) = registry

  assert definitions
    == dict.from_list([
      #("Math", #(reference.Definition(0), first_definition_registry)),
    ])
}

pub fn add_definitions_assigns_stable_references_test() {
  let math_registry = registry.add_typename(registry.new(), "Int")
  let text_registry = registry.add_typename(registry.new(), "String")
  let ignored_registry = registry.add_typename(registry.new(), "Boolean")

  let registry =
    registry.add_definitions(registry.new(), [
      #("Math", math_registry),
      #("Text", text_registry),
      #("Math", ignored_registry),
    ])

  let registry.Registry(definitions:, ..) = registry

  assert definitions
    == dict.from_list([
      #("Math", #(reference.Definition(0), math_registry)),
      #("Text", #(reference.Definition(1), text_registry)),
    ])
}
