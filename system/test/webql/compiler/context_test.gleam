import gleam/dict
import webql/compiler/context
import webql/compiler/reference

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
      #(["in"], reference.Port(0)),
      #(["math", "in"], reference.Port(1)),
      #(["in"], reference.Port(2)),
    ])

  let context.Context(inputs:, ..) = context

  assert inputs
    == dict.from_list([
      #(["in"], #(reference.Input(0), reference.Port(0))),
      #(["math", "in"], #(reference.Input(1), reference.Port(1))),
    ])
}

pub fn add_output_assigns_stable_reference_test() {
  let context =
    context.add_outputs(context.new(), [
      #(["out"], reference.Port(0)),
      #(["math", "out"], reference.Port(1)),
      #(["out"], reference.Port(2)),
    ])

  let context.Context(outputs:, ..) = context

  assert outputs
    == dict.from_list([
      #(["out"], #(reference.Output(0), reference.Port(0))),
      #(["math", "out"], #(reference.Output(1), reference.Port(1))),
    ])
}

pub fn add_node_assigns_stable_reference_test() {
  let context = context.add_nodes(context.new(), ["math", "text", "math"])

  let context.Context(nodes:, ..) = context

  assert nodes
    == dict.from_list([
      #("math", reference.Node(0)),
      #("text", reference.Node(1)),
    ])
}

pub fn add_edge_assigns_stable_reference_test() {
  let context =
    context.new()
    |> context.add_outputs([
      #(["math", "out"], reference.Port(0)),
      #(["value"], reference.Port(1)),
    ])
    |> context.add_inputs([
      #(["out"], reference.Port(0)),
      #(["text", "in"], reference.Port(1)),
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

pub fn add_supernode_assigns_stable_reference_test() {
  let context = context.add_supernodes(context.new(), ["Math", "Text", "Math"])

  let context.Context(supernodes:, ..) = context

  assert supernodes
    == dict.from_list([
      #("Math", reference.Supernode(0)),
      #("Text", reference.Supernode(1)),
    ])
}

pub fn add_context_keeps_existing_registration_test() {
  let first_nested_context = context.add_parameter(context.new(), "in")
  let second_nested_context = context.add_return(context.new(), "out")

  let context =
    context.new()
    |> context.add_context(reference.Supernode(0), first_nested_context)
    |> context.add_context(reference.Supernode(0), second_nested_context)

  let context.Context(contexts:, ..) = context

  assert contexts
    == dict.from_list([#(reference.Supernode(0), first_nested_context)])
}

pub fn get_input_returns_typed_registration_test() {
  let context = context.add_input(context.new(), ["in"], reference.Port(7))

  assert context.get_input(context, ["in"])
    == Ok(#(reference.Input(0), reference.Port(7)))
}

pub fn get_output_returns_typed_registration_test() {
  let context = context.add_output(context.new(), ["out"], reference.Port(9))

  assert context.get_output(context, ["out"])
    == Ok(#(reference.Output(0), reference.Port(9)))
}

pub fn get_node_returns_registered_reference_test() {
  let context = context.add_node(context.new(), "math")

  assert context.get_node(context, "math") == Ok(reference.Node(0))
}

pub fn get_supernode_returns_registered_reference_test() {
  let context = context.add_supernode(context.new(), "Math")

  assert context.get_supernode(context, "Math") == Ok(reference.Supernode(0))
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
  let ignored_context = context.add_node(context.new(), "value")

  let context =
    context.add_contexts(context.new(), [
      #(reference.Supernode(0), math_context),
      #(reference.Supernode(1), text_context),
      #(reference.Supernode(0), ignored_context),
    ])

  let context.Context(contexts:, ..) = context

  assert contexts
    == dict.from_list([
      #(reference.Supernode(0), math_context),
      #(reference.Supernode(1), text_context),
    ])
}

pub fn get_context_returns_registered_nested_context_test() {
  let nested_context = context.add_parameter(context.new(), "in")
  let context =
    context.add_context(context.new(), reference.Supernode(0), nested_context)

  assert context.get_context(context, reference.Supernode(0))
    == Ok(nested_context)
}
