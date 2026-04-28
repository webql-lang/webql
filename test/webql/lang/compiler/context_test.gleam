import gleam/dict
import webql/lang/compiler/context
import webql/lang/compiler/reference

pub fn add_parameter_assigns_stable_reference_test() {
  let context = context.add_parameters(context.new(), ["in", "value", "in"])

  let context.Context(parameters:, ..) = context

  assert parameters
    == dict.from_list([
      #("in", reference.Parameter(0)),
      #("value", reference.Parameter(1)),
    ])
}

pub fn add_return_assigns_stable_reference_test() {
  let context = context.add_returns(context.new(), ["out", "value", "out"])

  let context.Context(returns:, ..) = context

  assert returns
    == dict.from_list([
      #("out", reference.Return(0)),
      #("value", reference.Return(1)),
    ])
}

pub fn add_input_assigns_stable_reference_test() {
  let context =
    context.add_inputs(context.new(), [
      #(["in"], reference.Typename(0)),
      #(["math", "in"], reference.Typename(1)),
      #(["in"], reference.Typename(2)),
    ])

  let context.Context(inputs:, ..) = context

  assert inputs
    == dict.from_list([
      #(["in"], #(reference.Input(0), reference.Typename(0))),
      #(["math", "in"], #(reference.Input(1), reference.Typename(1))),
    ])
}

pub fn add_output_assigns_stable_reference_test() {
  let context =
    context.add_outputs(context.new(), [
      #(["out"], reference.Typename(0)),
      #(["math", "out"], reference.Typename(1)),
      #(["out"], reference.Typename(2)),
    ])

  let context.Context(outputs:, ..) = context

  assert outputs
    == dict.from_list([
      #(["out"], #(reference.Output(0), reference.Typename(0))),
      #(["math", "out"], #(reference.Output(1), reference.Typename(1))),
    ])
}

pub fn add_binding_assigns_stable_reference_test() {
  let context = context.add_bindings(context.new(), ["math", "text", "math"])

  let context.Context(bindings:, ..) = context

  assert bindings
    == dict.from_list([
      #("math", reference.Binding(0)),
      #("text", reference.Binding(1)),
    ])
}

pub fn add_edge_assigns_stable_reference_test() {
  let context =
    context.new()
    |> context.add_outputs([
      #(["math", "out"], reference.Typename(0)),
      #(["value"], reference.Typename(1)),
    ])
    |> context.add_inputs([
      #(["out"], reference.Typename(0)),
      #(["text", "in"], reference.Typename(1)),
    ])
    |> context.add_edges([
      reference.Input(0),
      reference.Input(1),
      reference.Input(0),
    ])

  let context.Context(edges:, ..) = context

  assert edges
    == dict.from_list([
      #(reference.Input(0), reference.Edge(0)),
      #(reference.Input(1), reference.Edge(1)),
    ])
}

pub fn add_definition_assigns_stable_reference_test() {
  let context = context.add_definitions(context.new(), ["Math", "Text", "Math"])

  let context.Context(definitions:, ..) = context

  assert definitions
    == dict.from_list([
      #("Math", reference.Definition(0)),
      #("Text", reference.Definition(1)),
    ])
}

pub fn add_context_keeps_existing_registration_test() {
  let first_nested_context = context.add_parameter(context.new(), "in")
  let second_nested_context = context.add_return(context.new(), "out")

  let context =
    context.new()
    |> context.add_context(reference.Definition(0), first_nested_context)
    |> context.add_context(reference.Definition(0), second_nested_context)

  let context.Context(contexts:, ..) = context

  assert contexts
    == dict.from_list([#(reference.Definition(0), first_nested_context)])
}

pub fn get_input_returns_typed_registration_test() {
  let context = context.add_input(context.new(), ["in"], reference.Typename(7))

  assert context.get_input(context, ["in"])
    == Ok(#(reference.Input(0), reference.Typename(7)))
}

pub fn get_output_returns_typed_registration_test() {
  let context =
    context.add_output(context.new(), ["out"], reference.Typename(9))

  assert context.get_output(context, ["out"])
    == Ok(#(reference.Output(0), reference.Typename(9)))
}

pub fn get_binding_returns_registered_reference_test() {
  let context = context.add_binding(context.new(), "math")

  assert context.get_binding(context, "math") == Ok(reference.Binding(0))
}

pub fn get_definition_returns_registered_reference_test() {
  let context = context.add_definition(context.new(), "Math")

  assert context.get_definition(context, "Math") == Ok(reference.Definition(0))
}

pub fn get_edge_returns_registered_reference_test() {
  let context = context.add_edge(context.new(), reference.Input(3))

  assert context.get_edge(context, reference.Input(3)) == Ok(reference.Edge(0))
}

pub fn get_parameter_returns_registered_reference_test() {
  let context = context.add_parameter(context.new(), "in")

  assert context.get_parameter(context, "in") == Ok(reference.Parameter(0))
}

pub fn get_return_returns_registered_reference_test() {
  let context = context.add_return(context.new(), "out")

  assert context.get_return(context, "out") == Ok(reference.Return(0))
}

pub fn add_contexts_registers_nested_contexts_test() {
  let math_context = context.add_parameter(context.new(), "in")
  let text_context = context.add_return(context.new(), "out")
  let ignored_context = context.add_binding(context.new(), "value")

  let context =
    context.add_contexts(context.new(), [
      #(reference.Definition(0), math_context),
      #(reference.Definition(1), text_context),
      #(reference.Definition(0), ignored_context),
    ])

  let context.Context(contexts:, ..) = context

  assert contexts
    == dict.from_list([
      #(reference.Definition(0), math_context),
      #(reference.Definition(1), text_context),
    ])
}

pub fn get_context_returns_registered_nested_context_test() {
  let nested_context = context.add_parameter(context.new(), "in")
  let context =
    context.add_context(context.new(), reference.Definition(0), nested_context)

  assert context.get_context(context, reference.Definition(0))
    == Ok(nested_context)
}
