import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/reference

pub type Environment {
  Environment(
    inputs: dict.Dict(reference.Operation, List(#(String, reference.Port))),
    operations: dict.Dict(String, reference.Operation),
    outputs: dict.Dict(reference.Operation, List(#(String, reference.Port))),
    ports: dict.Dict(String, reference.Port),
  )
}

/// Creates a new compiler environment.
pub fn new() -> Environment {
  Environment(
    inputs: dict.new(),
    operations: dict.new(),
    outputs: dict.new(),
    ports: dict.new(),
  )
}

/// Adds a schema operation to the current environment instance.
pub fn add_operation(
  environment: Environment,
  operation: String,
) -> Environment {
  let Environment(operations:, ..) = environment

  Environment(
    ..environment,
    operations: dict.upsert(operations, operation, fn(operation) {
      case operation {
        option.Some(operation) -> operation
        option.None -> next_operation(environment)
      }
    }),
  )
}

/// Adds schema operations to the current environment instance.
pub fn add_operations(
  environment: Environment,
  operations: List(String),
) -> Environment {
  list.fold(operations, environment, add_operation)
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
  operation: reference.Operation,
  input: #(String, reference.Port),
) -> Environment {
  let Environment(inputs:, ..) = environment

  Environment(
    ..environment,
    inputs: dict.upsert(inputs, operation, fn(existing) {
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
  operation: reference.Operation,
  inputs: List(#(String, reference.Port)),
) -> Environment {
  list.fold(inputs, environment, fn(environment, input) {
    add_input(environment, operation, input)
  })
}

/// Adds a typed output port to the current environment instance.
pub fn add_output(
  environment: Environment,
  operation: reference.Operation,
  output: #(String, reference.Port),
) -> Environment {
  let Environment(outputs:, ..) = environment

  Environment(
    ..environment,
    outputs: dict.upsert(outputs, operation, fn(existing) {
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
  operation: reference.Operation,
  outputs: List(#(String, reference.Port)),
) -> Environment {
  list.fold(outputs, environment, fn(environment, output) {
    add_output(environment, operation, output)
  })
}

/// Gets the next stable schema operation reference.
pub fn next_operation(environment: Environment) -> reference.Operation {
  reference.Operation(dict.size(environment.operations))
}

/// Gets the next stable port reference.
pub fn next_port(environment: Environment) -> reference.Port {
  reference.Port(dict.size(environment.ports))
}

/// Looks up typed input ports for an operation.
pub fn get_inputs(
  environment: Environment,
  operation: reference.Operation,
) -> Result(List(#(String, reference.Port)), Nil) {
  dict.get(environment.inputs, operation)
}

/// Looks up a schema operation reference by name.
pub fn get_operation(
  environment: Environment,
  operation: String,
) -> Result(reference.Operation, Nil) {
  dict.get(environment.operations, operation)
}

/// Looks up typed output ports for an operation.
pub fn get_outputs(
  environment: Environment,
  operation: reference.Operation,
) -> Result(List(#(String, reference.Port)), Nil) {
  dict.get(environment.outputs, operation)
}

/// Looks up a port reference by name.
pub fn get_port(
  environment: Environment,
  port: String,
) -> Result(reference.Port, Nil) {
  dict.get(environment.ports, port)
}
