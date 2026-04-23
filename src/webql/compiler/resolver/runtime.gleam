import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/resolver/reference

pub type Runtime {
  Runtime(
    bindings: dict.Dict(String, reference.Binding),
    definitions: dict.Dict(String, reference.Definition),
    edges: dict.Dict(reference.Input, reference.Edge),
    inputs: dict.Dict(List(String), reference.Input),
    outputs: dict.Dict(List(String), reference.Output),
    parameters: dict.Dict(String, reference.Parameter),
    returns: dict.Dict(String, reference.Return),
    runtimes: dict.Dict(reference.Definition, Runtime),
  )
}

/// Creates a new runtime.
pub fn new() -> Runtime {
  Runtime(
    bindings: dict.new(),
    definitions: dict.new(),
    edges: dict.new(),
    inputs: dict.new(),
    outputs: dict.new(),
    parameters: dict.new(),
    returns: dict.new(),
    runtimes: dict.new(),
  )
}

/// Adds a binding to the current runtime instance.
pub fn add_binding(runtime: Runtime, binding: String) -> Runtime {
  let Runtime(bindings:, ..) = runtime

  Runtime(
    ..runtime,
    bindings: dict.upsert(bindings, binding, fn(binding) {
      case binding {
        option.Some(binding) -> binding
        option.None -> next_binding(runtime)
      }
    }),
  )
}

/// Adds bindings to the current runtime instance.
pub fn add_bindings(runtime: Runtime, bindings: List(String)) -> Runtime {
  list.fold(bindings, runtime, add_binding)
}

/// Adds a definition to the current runtime instance.
pub fn add_definition(runtime: Runtime, definition: String) -> Runtime {
  let Runtime(definitions:, ..) = runtime

  Runtime(
    ..runtime,
    definitions: dict.upsert(definitions, definition, fn(definition) {
      case definition {
        option.Some(definition) -> definition
        option.None -> next_definition(runtime)
      }
    }),
  )
}

/// Adds definitions to the current runtime instance.
pub fn add_definitions(runtime: Runtime, definitions: List(String)) -> Runtime {
  list.fold(definitions, runtime, add_definition)
}

/// Adds an edge to the current runtime instance.
pub fn add_edge(runtime: Runtime, edge: reference.Input) -> Runtime {
  let Runtime(edges:, ..) = runtime

  Runtime(
    ..runtime,
    edges: dict.upsert(edges, edge, fn(edge) {
      case edge {
        option.Some(edge) -> edge
        option.None -> next_edge(runtime)
      }
    }),
  )
}

/// Adds edges to the current runtime instance.
pub fn add_edges(runtime: Runtime, edges: List(reference.Input)) -> Runtime {
  list.fold(edges, runtime, add_edge)
}

/// Adds an input to the current runtime instance.
pub fn add_input(runtime: Runtime, input: List(String)) -> Runtime {
  let Runtime(inputs:, ..) = runtime

  Runtime(
    ..runtime,
    inputs: dict.upsert(inputs, input, fn(input) {
      case input {
        option.Some(input) -> input
        option.None -> next_input(runtime)
      }
    }),
  )
}

/// Adds inputs to the current runtime instance.
pub fn add_inputs(runtime: Runtime, inputs: List(List(String))) -> Runtime {
  list.fold(inputs, runtime, add_input)
}

/// Adds an output to the current runtime instance.
pub fn add_output(runtime: Runtime, output: List(String)) -> Runtime {
  let Runtime(outputs:, ..) = runtime

  Runtime(
    ..runtime,
    outputs: dict.upsert(outputs, output, fn(output) {
      case output {
        option.Some(output) -> output
        option.None -> next_output(runtime)
      }
    }),
  )
}

/// Adds outputs to the current runtime instance.
pub fn add_outputs(runtime: Runtime, outputs: List(List(String))) -> Runtime {
  list.fold(outputs, runtime, add_output)
}

/// Adds a parameter to the current runtime instance.
pub fn add_parameter(runtime: Runtime, parameter: String) -> Runtime {
  let Runtime(parameters:, ..) = runtime

  Runtime(
    ..runtime,
    parameters: dict.upsert(parameters, parameter, fn(parameter) {
      case parameter {
        option.Some(parameter) -> parameter
        option.None -> next_parameter(runtime)
      }
    }),
  )
}

/// Adds parameters to the current runtime instance.
pub fn add_parameters(runtime: Runtime, parameters: List(String)) -> Runtime {
  list.fold(parameters, runtime, add_parameter)
}

/// Adds a return to the current runtime instance.
pub fn add_return(runtime: Runtime, return: String) -> Runtime {
  let Runtime(returns:, ..) = runtime

  Runtime(
    ..runtime,
    returns: dict.upsert(returns, return, fn(return) {
      case return {
        option.Some(return) -> return
        option.None -> next_return(runtime)
      }
    }),
  )
}

/// Adds returns to the current runtime instance.
pub fn add_returns(runtime: Runtime, returns: List(String)) -> Runtime {
  list.fold(returns, runtime, add_return)
}

/// Adds a nested runtime to the current runtime instance.
pub fn add_runtime(
  runtime: Runtime,
  definition: reference.Definition,
  nested_runtime: Runtime,
) -> Runtime {
  let Runtime(runtimes:, ..) = runtime

  Runtime(
    ..runtime,
    runtimes: dict.upsert(runtimes, definition, fn(existing_runtime) {
      case existing_runtime {
        option.Some(existing_runtime) -> existing_runtime
        option.None -> nested_runtime
      }
    }),
  )
}

/// Adds nested runtimes to the current runtime instance.
pub fn add_runtimes(
  runtime: Runtime,
  runtimes: List(#(reference.Definition, Runtime)),
) -> Runtime {
  list.fold(runtimes, runtime, fn(runtime, entry) {
    let #(definition, nested_runtime) = entry
    add_runtime(runtime, definition, nested_runtime)
  })
}

/// Gets the next stable binding reference.
pub fn next_binding(runtime: Runtime) -> reference.Binding {
  reference.Binding(dict.size(runtime.bindings))
}

/// Gets the next stable definition reference.
pub fn next_definition(runtime: Runtime) -> reference.Definition {
  reference.Definition(dict.size(runtime.definitions))
}

/// Gets the next stable edge reference.
pub fn next_edge(runtime: Runtime) -> reference.Edge {
  reference.Edge(dict.size(runtime.edges))
}

/// Gets the next stable input reference.
pub fn next_input(runtime: Runtime) -> reference.Input {
  reference.Input(dict.size(runtime.inputs))
}

/// Gets the next stable output reference.
pub fn next_output(runtime: Runtime) -> reference.Output {
  reference.Output(dict.size(runtime.outputs))
}

/// Gets the next stable parameter reference.
pub fn next_parameter(runtime: Runtime) -> reference.Parameter {
  reference.Parameter(dict.size(runtime.parameters))
}

/// Gets the next stable return reference.
pub fn next_return(runtime: Runtime) -> reference.Return {
  reference.Return(dict.size(runtime.returns))
}
