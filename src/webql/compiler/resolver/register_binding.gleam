import gleam/list
import webql/compiler/environment
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/runtime

/// Registers a binding.
pub fn register(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  binding: ast.Binding,
) -> runtime.Runtime {
  let runtime = runtime.add_binding(runtime, binding.name)

  case binding.value {
    ast.NodeValue(reference: node, ..) ->
      register_node_value(runtime, environment, binding.name, node)
  }
}

// PRIVATE FUNCTIONS
// =================
fn register_node_value(
  runtime: runtime.Runtime,
  environment: environment.Environment,
  name: String,
  node: reference.Node,
) {
  let runtime = case environment.get_inputs(environment, node) {
    Ok(inputs) -> register_inputs(runtime, name, inputs)
    Error(_nil) -> runtime
  }

  case environment.get_outputs(environment, node) {
    Ok(outputs) -> register_outputs(runtime, name, outputs)
    Error(_nil) -> runtime
  }
}

fn register_inputs(
  runtime: runtime.Runtime,
  name: String,
  inputs: List(#(String, reference.Typename)),
) {
  list.fold(inputs, runtime, fn(runtime, input) {
    let #(port, typename) = input
    runtime.add_input(runtime, [name, port], typename)
  })
}

fn register_outputs(
  runtime: runtime.Runtime,
  name: String,
  outputs: List(#(String, reference.Typename)),
) {
  list.fold(outputs, runtime, fn(runtime, output) {
    let #(port, typename) = output
    runtime.add_output(runtime, [name, port], typename)
  })
}
