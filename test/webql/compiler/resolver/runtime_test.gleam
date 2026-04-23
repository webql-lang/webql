import gleam/dict
import webql/compiler/resolver/reference
import webql/compiler/resolver/runtime

pub fn add_parameter_assigns_stable_reference_test() {
  let runtime = runtime.add_parameters(runtime.new(), ["in", "value", "in"])

  let runtime.Runtime(parameters:, ..) = runtime

  assert parameters
    == dict.from_list([
      #("in", reference.Parameter(0)),
      #("value", reference.Parameter(1)),
    ])
}

pub fn add_return_assigns_stable_reference_test() {
  let runtime = runtime.add_returns(runtime.new(), ["out", "value", "out"])

  let runtime.Runtime(returns:, ..) = runtime

  assert returns
    == dict.from_list([
      #("out", reference.Return(0)),
      #("value", reference.Return(1)),
    ])
}

pub fn add_input_assigns_stable_reference_test() {
  let runtime =
    runtime.add_inputs(runtime.new(), [["in"], ["math", "in"], ["in"]])

  let runtime.Runtime(inputs:, ..) = runtime

  assert inputs
    == dict.from_list([
      #(["in"], reference.Input(0)),
      #(["math", "in"], reference.Input(1)),
    ])
}

pub fn add_output_assigns_stable_reference_test() {
  let runtime =
    runtime.add_outputs(runtime.new(), [["out"], ["math", "out"], ["out"]])

  let runtime.Runtime(outputs:, ..) = runtime

  assert outputs
    == dict.from_list([
      #(["out"], reference.Output(0)),
      #(["math", "out"], reference.Output(1)),
    ])
}

pub fn add_binding_assigns_stable_reference_test() {
  let runtime = runtime.add_bindings(runtime.new(), ["math", "text", "math"])

  let runtime.Runtime(bindings:, ..) = runtime

  assert bindings
    == dict.from_list([
      #("math", reference.Binding(0)),
      #("text", reference.Binding(1)),
    ])
}

pub fn add_edge_assigns_stable_reference_test() {
  let runtime =
    runtime.new()
    |> runtime.add_outputs([["math", "out"], ["value"]])
    |> runtime.add_inputs([["out"], ["text", "in"]])
    |> runtime.add_edges([
      reference.Input(0),
      reference.Input(1),
      reference.Input(0),
    ])

  let runtime.Runtime(edges:, ..) = runtime

  assert edges
    == dict.from_list([
      #(reference.Input(0), reference.Edge(0)),
      #(reference.Input(1), reference.Edge(1)),
    ])
}

pub fn add_definition_assigns_stable_reference_test() {
  let runtime = runtime.add_definitions(runtime.new(), ["Math", "Text", "Math"])

  let runtime.Runtime(definitions:, ..) = runtime

  assert definitions
    == dict.from_list([
      #("Math", reference.Definition(0)),
      #("Text", reference.Definition(1)),
    ])
}

pub fn add_runtime_keeps_existing_registration_test() {
  let first_nested_runtime = runtime.add_parameter(runtime.new(), "in")
  let second_nested_runtime = runtime.add_return(runtime.new(), "out")

  let runtime =
    runtime.new()
    |> runtime.add_runtime(reference.Definition(0), first_nested_runtime)
    |> runtime.add_runtime(reference.Definition(0), second_nested_runtime)

  let runtime.Runtime(runtimes:, ..) = runtime

  assert runtimes
    == dict.from_list([#(reference.Definition(0), first_nested_runtime)])
}

pub fn add_runtimes_registers_nested_runtimes_test() {
  let math_runtime = runtime.add_parameter(runtime.new(), "in")
  let text_runtime = runtime.add_return(runtime.new(), "out")
  let ignored_runtime = runtime.add_binding(runtime.new(), "value")

  let runtime =
    runtime.add_runtimes(runtime.new(), [
      #(reference.Definition(0), math_runtime),
      #(reference.Definition(1), text_runtime),
      #(reference.Definition(0), ignored_runtime),
    ])

  let runtime.Runtime(runtimes:, ..) = runtime

  assert runtimes
    == dict.from_list([
      #(reference.Definition(0), math_runtime),
      #(reference.Definition(1), text_runtime),
    ])
}
