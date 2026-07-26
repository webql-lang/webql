import gleam/list
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/reference
import webql/compiler/resolver/hir

/// Registers a node.
pub fn register(
  environment: environment.Environment,
  context: context.Context,
  node: hir.Node,
) -> context.Context {
  let context = context.add_node(context, node.name)

  case node {
    hir.Node(name:, node:, ..) -> {
      case environment.get_node(environment, node) {
        Ok(reference) ->
          register_node_ports(context, environment, name, reference)

        Error(_nil) -> context
      }
    }

    hir.Supernode(..) -> context
  }
}

// PRIVATE FUNCTIONS
// =================
fn register_node_ports(
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
  inputs: List(#(String, reference.Port)),
) {
  list.fold(inputs, context, fn(context, input) {
    let #(port, reference) = input
    context.add_input(context, [name, port], reference)
  })
}

fn register_outputs(
  context: context.Context,
  name: String,
  outputs: List(#(String, reference.Port)),
) {
  list.fold(outputs, context, fn(context, output) {
    let #(port, reference) = output
    context.add_output(context, [name, port], reference)
  })
}
