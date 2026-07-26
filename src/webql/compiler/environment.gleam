import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/reference

pub type Environment {
  Environment(
    inputs: dict.Dict(String, List(#(String, reference.Port))),
    nodes: dict.Dict(String, Nil),
    outputs: dict.Dict(String, List(#(String, reference.Port))),
    ports: dict.Dict(String, reference.Port),
  )
}

/// Creates a new compiler environment.
pub fn new() -> Environment {
  Environment(
    inputs: dict.new(),
    nodes: dict.new(),
    outputs: dict.new(),
    ports: dict.new(),
  )
}

/// Adds a schema node to the current environment instance.
pub fn add_node(environment: Environment, node: String) -> Environment {
  let Environment(nodes:, ..) = environment

  Environment(..environment, nodes: dict.insert(nodes, node, Nil))
}

/// Adds schema nodes to the current environment instance.
pub fn add_nodes(environment: Environment, nodes: List(String)) -> Environment {
  list.fold(nodes, environment, add_node)
}

/// Adds a port to the current environment instance.
pub fn add_port(environment: Environment, port: String) -> Environment {
  let Environment(ports:, ..) = environment

  Environment(
    ..environment,
    ports: dict.upsert(ports, port, fn(port) {
      case port {
        option.Some(port) -> port
        option.None -> next_port(environment)
      }
    }),
  )
}

/// Adds ports to the current environment instance.
pub fn add_ports(environment: Environment, ports: List(String)) -> Environment {
  list.fold(ports, environment, add_port)
}

/// Adds a typed input port to the current environment instance.
pub fn add_input(
  environment: Environment,
  node: String,
  input: #(String, reference.Port),
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
  node: String,
  inputs: List(#(String, reference.Port)),
) -> Environment {
  list.fold(inputs, environment, fn(environment, input) {
    add_input(environment, node, input)
  })
}

/// Adds a typed output port to the current environment instance.
pub fn add_output(
  environment: Environment,
  node: String,
  output: #(String, reference.Port),
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
  node: String,
  outputs: List(#(String, reference.Port)),
) -> Environment {
  list.fold(outputs, environment, fn(environment, output) {
    add_output(environment, node, output)
  })
}

/// Gets the next stable port reference.
pub fn next_port(environment: Environment) -> reference.Port {
  reference.Port(dict.size(environment.ports))
}

/// Looks up typed input ports for a schema node.
pub fn get_inputs(
  environment: Environment,
  node: String,
) -> Result(List(#(String, reference.Port)), Nil) {
  dict.get(environment.inputs, node)
}

/// Checks whether a schema node exists by name.
pub fn get_node(environment: Environment, node: String) -> Result(Nil, Nil) {
  dict.get(environment.nodes, node)
}

/// Looks up typed output ports for a schema node.
pub fn get_outputs(
  environment: Environment,
  node: String,
) -> Result(List(#(String, reference.Port)), Nil) {
  dict.get(environment.outputs, node)
}

/// Looks up a port reference by name.
pub fn get_port(
  environment: Environment,
  port: String,
) -> Result(reference.Port, Nil) {
  dict.get(environment.ports, port)
}
