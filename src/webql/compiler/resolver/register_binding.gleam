import gleam/list
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/reference
import webql/compiler/resolver/ast

/// Registers a binding.
pub fn register(
  environment: environment.Environment,
  context: context.Context,
  binding: ast.Binding,
) -> context.Context {
  let context = context.add_binding(context, binding.name)

  case binding.value {
    ast.NodeValue(reference: node, ..) ->
      register_node_value(context, environment, binding.name, node)
  }
}

// PRIVATE FUNCTIONS
// =================
fn register_node_value(
  context: context.Context,
  environment: environment.Environment,
  name: String,
  node: reference.Node,
) {
  let context = case environment.get_inputs(environment, node) {
    Ok(inputs) -> register_inputs(context, name, inputs)
    Error(_nil) -> context
  }

  case environment.get_outputs(environment, node) {
    Ok(outputs) -> register_outputs(context, name, outputs)
    Error(_nil) -> context
  }
}

fn register_inputs(
  context: context.Context,
  name: String,
  inputs: List(#(String, reference.Typename)),
) {
  list.fold(inputs, context, fn(context, input) {
    let #(port, typename) = input
    context.add_input(context, [name, port], typename)
  })
}

fn register_outputs(
  context: context.Context,
  name: String,
  outputs: List(#(String, reference.Typename)),
) {
  list.fold(outputs, context, fn(context, output) {
    let #(port, typename) = output
    context.add_output(context, [name, port], typename)
  })
}
