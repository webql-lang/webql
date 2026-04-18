import gleam/dict
import gleam/list
import gleam/option
import webql/lang/resolver/reference

/// A registry with resolver context.
pub type Registry {
  Registry(
    parameters: dict.Dict(List(String), reference.Parameter),
    returns: dict.Dict(List(String), reference.Return),
    inputs: dict.Dict(List(String), reference.Input),
    outputs: dict.Dict(List(String), reference.Output),
    definitions: dict.Dict(String, #(reference.Definition, Registry)),
    bindings: dict.Dict(List(String), reference.Binding),
    edges: dict.Dict(#(List(String), List(String)), reference.Edge),
    nodes: dict.Dict(String, reference.Node),
    typenames: dict.Dict(String, reference.Typename),
  )
}

/// Creates a registry.
pub fn new() -> Registry {
  Registry(
    typenames: dict.new(),
    nodes: dict.new(),
    parameters: dict.new(),
    returns: dict.new(),
    inputs: dict.new(),
    outputs: dict.new(),
    definitions: dict.new(),
    bindings: dict.new(),
    edges: dict.new(),
  )
}

/// Adds typenames to the current registry instance.
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

/// Adds typenames to the current registry instance.
pub fn add_typenames(registry: Registry, typenames: List(String)) -> Registry {
  list.fold(typenames, registry, add_typename)
}

/// Adds nodes to the current registry instance.
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

/// Adds nodes to the current registry instance.
pub fn add_nodes(registry: Registry, nodes: List(String)) -> Registry {
  list.fold(nodes, registry, add_node)
}

/// Adds a parameter to the current registry instance.
pub fn add_parameter(registry: Registry, parameter: List(String)) -> Registry {
  let Registry(parameters:, ..) = registry

  Registry(
    ..registry,
    parameters: dict.upsert(parameters, parameter, fn(parameter) {
      case parameter {
        option.Some(parameter) -> parameter
        option.None -> next_parameter(registry)
      }
    }),
  )
}

/// Adds parameters to the current registry instance.
pub fn add_parameters(
  registry: Registry,
  parameters: List(List(String)),
) -> Registry {
  list.fold(parameters, registry, add_parameter)
}

/// Adds a return to the current registry instance.
pub fn add_return(registry: Registry, return: List(String)) -> Registry {
  let Registry(returns:, ..) = registry

  Registry(
    ..registry,
    returns: dict.upsert(returns, return, fn(return) {
      case return {
        option.Some(return) -> return
        option.None -> next_return(registry)
      }
    }),
  )
}

/// Adds returns to the current registry instance.
pub fn add_returns(registry: Registry, returns: List(List(String))) -> Registry {
  list.fold(returns, registry, add_return)
}

/// Adds a input to the current registry instance.
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

/// Adds a output to the current registry instance.
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

/// Adds an edge to the current registry instance.
pub fn add_edge(
  registry: Registry,
  edge: #(List(String), List(String)),
) -> Registry {
  let Registry(edges:, ..) = registry

  Registry(
    ..registry,
    edges: dict.upsert(edges, edge, fn(edge) {
      case edge {
        option.Some(edge) -> edge
        option.None -> next_edge(registry)
      }
    }),
  )
}

/// Adds edges to the current registry instance.
pub fn add_edges(
  registry: Registry,
  edges: List(#(List(String), List(String))),
) -> Registry {
  list.fold(edges, registry, add_edge)
}

/// Adds a definition to the current registry instance.
pub fn add_definition(
  registry: Registry,
  name: String,
  value: Registry,
) -> Registry {
  let Registry(definitions:, ..) = registry

  Registry(
    ..registry,
    definitions: dict.upsert(definitions, name, fn(definition) {
      case definition {
        option.Some(definition) -> definition
        option.None -> #(next_definition(registry), value)
      }
    }),
  )
}

/// Adds definitions to the current registry instance.
pub fn add_definitions(
  registry: Registry,
  definitions: List(#(String, Registry)),
) -> Registry {
  list.fold(definitions, registry, fn(registry, definition) {
    let #(name, value) = definition
    add_definition(registry, name, value)
  })
}

// PRIVATE FUNCTIONS
// =================
fn next_binding(registry: Registry) -> reference.Binding {
  reference.Binding(dict.size(registry.bindings))
}

fn next_definition(registry: Registry) -> reference.Definition {
  reference.Definition(dict.size(registry.definitions))
}

fn next_edge(registry: Registry) -> reference.Edge {
  reference.Edge(dict.size(registry.edges))
}

fn next_parameter(registry: Registry) -> reference.Parameter {
  reference.Parameter(dict.size(registry.parameters))
}

fn next_return(registry: Registry) -> reference.Return {
  reference.Return(dict.size(registry.returns))
}

fn next_input(registry: Registry) -> reference.Input {
  reference.Input(dict.size(registry.inputs))
}

fn next_output(registry: Registry) -> reference.Output {
  reference.Output(dict.size(registry.outputs))
}

fn next_typename(registry: Registry) -> reference.Typename {
  reference.Typename(dict.size(registry.typenames))
}

fn next_node(registry: Registry) -> reference.Node {
  reference.Node(dict.size(registry.nodes))
}
