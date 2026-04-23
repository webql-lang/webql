import gleam/dict
import gleam/list
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema

/// Registers a binding.
pub fn register(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  binding: ast.Binding,
) -> runtime.Runtime {
  let runtime = runtime.add_binding(runtime, binding.name)

  case binding.value {
    ast.NodeValue(reference: node, ..) ->
      register_node_value(runtime, schema, binding.name, node)

    _primative -> runtime
  }
}

// PRIVATE FUNCTIONS
// =================
fn register_node_value(
  runtime: runtime.Runtime,
  schema: schema.Schema,
  name: String,
  node: reference.Node,
) {
  let runtime = case dict.get(schema.inputs, node) {
    Ok(inputs) -> register_inputs(runtime, name, inputs)
    Error(_nil) -> runtime
  }

  case dict.get(schema.outputs, node) {
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
