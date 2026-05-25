import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/reference

pub type Environment {
  Environment(
    inputs: dict.Dict(reference.Node, List(#(String, reference.Typename))),
    nodes: dict.Dict(String, reference.Node),
    outputs: dict.Dict(reference.Node, List(#(String, reference.Typename))),
    typenames: dict.Dict(String, reference.Typename),
  )
}

/// Creates a new compiler environment.
pub fn new() -> Environment {
  Environment(
    inputs: dict.new(),
    nodes: dict.new(),
    outputs: dict.new(),
    typenames: dict.new(),
  )
}

/// Adds a node to the current environment instance.
pub fn add_node(environment: Environment, node: String) -> Environment {
  let Environment(nodes:, ..) = environment

  Environment(
    ..environment,
    nodes: dict.upsert(nodes, node, fn(node) {
      case node {
        option.Some(node) -> node
        option.None -> next_node(environment)
      }
    }),
  )
}

/// Adds nodes to the current environment instance.
pub fn add_nodes(environment: Environment, nodes: List(String)) -> Environment {
  list.fold(nodes, environment, add_node)
}

/// Adds a type to the current environment instance.
pub fn add_typename(environment: Environment, typename: String) -> Environment {
  let Environment(typenames:, ..) = environment

  Environment(
    ..environment,
    typenames: dict.upsert(typenames, typename, fn(typename) {
      case typename {
        option.Some(typename) -> typename
        option.None -> next_typename(environment)
      }
    }),
  )
}

/// Adds types to the current environment instance.
pub fn add_typenames(
  environment: Environment,
  typenames: List(String),
) -> Environment {
  list.fold(typenames, environment, add_typename)
}

/// Adds a typed input port to the current environment instance.
pub fn add_input(
  environment: Environment,
  node: reference.Node,
  input: #(String, reference.Typename),
) -> Environment {
  let Environment(inputs:, ..) = environment

  Environment(
    ..environment,
    inputs: dict.upsert(inputs, node, fn(existing) {
      case existing {
        option.Some(existing) -> list.append(existing, [input])
        option.None -> [input]
      }
    }),
  )
}

/// Adds typed input ports to the current environment instance.
pub fn add_inputs(
  environment: Environment,
  node: reference.Node,
  inputs: List(#(String, reference.Typename)),
) -> Environment {
  list.fold(inputs, environment, fn(environment, input) {
    add_input(environment, node, input)
  })
}

/// Adds a typed output port to the current environment instance.
pub fn add_output(
  environment: Environment,
  node: reference.Node,
  output: #(String, reference.Typename),
) -> Environment {
  let Environment(outputs:, ..) = environment

  Environment(
    ..environment,
    outputs: dict.upsert(outputs, node, fn(existing) {
      case existing {
        option.Some(existing) -> list.append(existing, [output])
        option.None -> [output]
      }
    }),
  )
}

/// Adds typed output ports to the current environment instance.
pub fn add_outputs(
  environment: Environment,
  node: reference.Node,
  outputs: List(#(String, reference.Typename)),
) -> Environment {
  list.fold(outputs, environment, fn(environment, output) {
    add_output(environment, node, output)
  })
}

/// Gets the next stable node reference.
pub fn next_node(environment: Environment) -> reference.Node {
  reference.Node(dict.size(environment.nodes))
}

/// Gets the next stable type reference.
pub fn next_typename(environment: Environment) -> reference.Typename {
  reference.Typename(dict.size(environment.typenames))
}

/// Looks up typed input ports for a node.
pub fn get_inputs(
  environment: Environment,
  node: reference.Node,
) -> Result(List(#(String, reference.Typename)), Nil) {
  dict.get(environment.inputs, node)
}

/// Looks up a node reference by name.
pub fn get_node(
  environment: Environment,
  node: String,
) -> Result(reference.Node, Nil) {
  dict.get(environment.nodes, node)
}

/// Looks up typed output ports for a node.
pub fn get_outputs(
  environment: Environment,
  node: reference.Node,
) -> Result(List(#(String, reference.Typename)), Nil) {
  dict.get(environment.outputs, node)
}

/// Looks up a type reference by name.
pub fn get_typename(
  environment: Environment,
  typename: String,
) -> Result(reference.Typename, Nil) {
  dict.get(environment.typenames, typename)
}
