import gleam/dict
import gleam/list
import gleam/option
import webql/lang/resolver/reference

/// A registry with resolver context.
pub type Registry {
  Registry(
    inputs: dict.Dict(List(String), reference.Input),
    outputs: dict.Dict(List(String), reference.Output),
    bindings: dict.Dict(List(String), reference.Binding),
    nodes: dict.Dict(String, reference.Node),
    operations: dict.Dict(String, #(reference.Operation, Registry)),
    typenames: dict.Dict(String, reference.Typename),
  )
}

/// Creates a registry.
pub fn new() -> Registry {
  Registry(
    typenames: dict.new(),
    nodes: dict.new(),
    inputs: dict.new(),
    outputs: dict.new(),
    operations: dict.new(),
    bindings: dict.new(),
  )
}

/// Adds typenames to the cuurent registry instance.
pub fn add_typename(registry: Registry, typename: String) -> Registry {
  let Registry(typenames:, ..) = registry

  Registry(
    ..registry,
    typenames: dict.upsert(typenames, typename, fn(typename) {
      case typename {
        option.Some(typename) -> typename
        option.None -> next_typename(registry)
      }
    }),
  )
}

/// Adds typenames to the cuurent registry instance.
pub fn add_typenames(registry: Registry, typenames: List(String)) -> Registry {
  list.fold(typenames, registry, add_typename)
}

/// Adds nodes to the cuurent registry instance.
pub fn add_node(registry: Registry, node: String) -> Registry {
  let Registry(nodes:, ..) = registry

  Registry(
    ..registry,
    nodes: dict.upsert(nodes, node, fn(node) {
      case node {
        option.Some(node) -> node
        option.None -> next_node(registry)
      }
    }),
  )
}

/// Adds nodes to the cuurent registry instance.
pub fn add_nodes(registry: Registry, nodes: List(String)) -> Registry {
  list.fold(nodes, registry, add_node)
}

/// Adds an input to the current registry instance.
pub fn add_input(registry: Registry, input: List(String)) -> Registry {
  let Registry(inputs:, ..) = registry

  Registry(
    ..registry,
    inputs: dict.upsert(inputs, input, fn(input) {
      case input {
        option.Some(input) -> input
        option.None -> next_input(registry)
      }
    }),
  )
}

/// Adds inputs to the current registry instance.
pub fn add_inputs(registry: Registry, inputs: List(List(String))) -> Registry {
  list.fold(inputs, registry, add_input)
}

/// Adds an output to the current registry instance.
pub fn add_output(registry: Registry, output: List(String)) -> Registry {
  let Registry(outputs:, ..) = registry

  Registry(
    ..registry,
    outputs: dict.upsert(outputs, output, fn(output) {
      case output {
        option.Some(output) -> output
        option.None -> next_output(registry)
      }
    }),
  )
}

/// Adds outputs to the current registry instance.
pub fn add_outputs(registry: Registry, outputs: List(List(String))) -> Registry {
  list.fold(outputs, registry, add_output)
}

/// Adds a binding to the current registry instance.
pub fn add_binding(registry: Registry, binding: List(String)) -> Registry {
  let Registry(bindings:, ..) = registry

  Registry(
    ..registry,
    bindings: dict.upsert(bindings, binding, fn(binding) {
      case binding {
        option.Some(binding) -> binding
        option.None -> next_binding(registry)
      }
    }),
  )
}

/// Adds bindings to the current registry instance.
pub fn add_bindings(
  registry: Registry,
  bindings: List(List(String)),
) -> Registry {
  list.fold(bindings, registry, add_binding)
}

/// Adds an operation to the current registry instance.
pub fn add_operation(
  registry: Registry,
  name: String,
  sub_registry: Registry,
) -> Registry {
  let Registry(operations:, ..) = registry

  Registry(
    ..registry,
    operations: dict.upsert(operations, name, fn(operation) {
      case operation {
        option.Some(operation) -> operation
        option.None -> #(next_operation(registry), sub_registry)
      }
    }),
  )
}

// PRIVATE FUNCTIONS
// =================
fn next_binding(registry: Registry) -> reference.Binding {
  reference.Binding(dict.size(registry.bindings))
}

fn next_input(registry: Registry) -> reference.Input {
  reference.Input(dict.size(registry.inputs))
}

fn next_output(registry: Registry) -> reference.Output {
  reference.Output(dict.size(registry.outputs))
}

fn next_operation(registry: Registry) -> reference.Operation {
  reference.Operation(dict.size(registry.operations))
}

fn next_typename(registry: Registry) -> reference.Typename {
  reference.Typename(dict.size(registry.typenames))
}

fn next_node(registry: Registry) -> reference.Node {
  reference.Node(dict.size(registry.nodes))
}
