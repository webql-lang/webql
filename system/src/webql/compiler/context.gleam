import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/reference

pub type Context {
  Context(
    bindings: dict.Dict(String, reference.Binding),
    definitions: dict.Dict(String, reference.Definition),
    edges: dict.Dict(reference.Input, reference.Edge),
    inputs: dict.Dict(List(String), #(reference.Input, reference.Typename)),
    outputs: dict.Dict(List(String), #(reference.Output, reference.Typename)),
    parameters: dict.Dict(String, reference.Parameter),
    returns: dict.Dict(String, reference.Return),
    contexts: dict.Dict(reference.Definition, Context),
  )
}

/// Creates a new context.
pub fn new() -> Context {
  Context(
    bindings: dict.new(),
    definitions: dict.new(),
    edges: dict.new(),
    inputs: dict.new(),
    outputs: dict.new(),
    parameters: dict.new(),
    returns: dict.new(),
    contexts: dict.new(),
  )
}

/// Adds a binding to the current context instance.
pub fn add_binding(context: Context, binding: String) -> Context {
  let Context(bindings:, ..) = context

  Context(
    ..context,
    bindings: dict.upsert(bindings, binding, fn(binding) {
      case binding {
        option.Some(binding) -> binding
        option.None -> next_binding(context)
      }
    }),
  )
}

/// Adds bindings to the current context instance.
pub fn add_bindings(context: Context, bindings: List(String)) -> Context {
  list.fold(bindings, context, add_binding)
}

/// Adds a definition to the current context instance.
pub fn add_definition(context: Context, definition: String) -> Context {
  let Context(definitions:, ..) = context

  Context(
    ..context,
    definitions: dict.upsert(definitions, definition, fn(definition) {
      case definition {
        option.Some(definition) -> definition
        option.None -> next_definition(context)
      }
    }),
  )
}

/// Adds definitions to the current context instance.
pub fn add_definitions(context: Context, definitions: List(String)) -> Context {
  list.fold(definitions, context, add_definition)
}

/// Adds an edge to the current context instance.
pub fn add_edge(context: Context, edge: reference.Input) -> Context {
  let Context(edges:, ..) = context

  Context(
    ..context,
    edges: dict.upsert(edges, edge, fn(edge) {
      case edge {
        option.Some(edge) -> edge
        option.None -> next_edge(context)
      }
    }),
  )
}

/// Adds edges to the current context instance.
pub fn add_edges(context: Context, edges: List(reference.Input)) -> Context {
  list.fold(edges, context, add_edge)
}

/// Adds a typed input to the current context instance.
pub fn add_input(
  context: Context,
  input: List(String),
  typename: reference.Typename,
) -> Context {
  let Context(inputs:, ..) = context

  Context(
    ..context,
    inputs: dict.upsert(inputs, input, fn(input) {
      case input {
        option.Some(input) -> input
        option.None -> #(next_input(context), typename)
      }
    }),
  )
}

/// Adds typed inputs to the current context instance.
pub fn add_inputs(
  context: Context,
  inputs: List(#(List(String), reference.Typename)),
) -> Context {
  list.fold(inputs, context, fn(context, input) {
    let #(path, typename) = input
    add_input(context, path, typename)
  })
}

/// Adds a typed output to the current context instance.
pub fn add_output(
  context: Context,
  output: List(String),
  typename: reference.Typename,
) -> Context {
  let Context(outputs:, ..) = context

  Context(
    ..context,
    outputs: dict.upsert(outputs, output, fn(output) {
      case output {
        option.Some(output) -> output
        option.None -> #(next_output(context), typename)
      }
    }),
  )
}

/// Adds typed outputs to the current context instance.
pub fn add_outputs(
  context: Context,
  outputs: List(#(List(String), reference.Typename)),
) -> Context {
  list.fold(outputs, context, fn(context, output) {
    let #(path, typename) = output
    add_output(context, path, typename)
  })
}

/// Adds a parameter to the current context instance.
pub fn add_parameter(context: Context, parameter: String) -> Context {
  let Context(parameters:, ..) = context

  Context(
    ..context,
    parameters: dict.upsert(parameters, parameter, fn(parameter) {
      case parameter {
        option.Some(parameter) -> parameter
        option.None -> next_parameter(context)
      }
    }),
  )
}

/// Adds parameters to the current context instance.
pub fn add_parameters(context: Context, parameters: List(String)) -> Context {
  list.fold(parameters, context, add_parameter)
}

/// Adds a return to the current context instance.
pub fn add_return(context: Context, return: String) -> Context {
  let Context(returns:, ..) = context

  Context(
    ..context,
    returns: dict.upsert(returns, return, fn(return) {
      case return {
        option.Some(return) -> return
        option.None -> next_return(context)
      }
    }),
  )
}

/// Adds returns to the current context instance.
pub fn add_returns(context: Context, returns: List(String)) -> Context {
  list.fold(returns, context, add_return)
}

/// Adds a nested context to the current context instance.
pub fn add_context(
  context: Context,
  definition: reference.Definition,
  nested_context: Context,
) -> Context {
  let Context(contexts:, ..) = context

  Context(
    ..context,
    contexts: dict.upsert(contexts, definition, fn(existing_context) {
      case existing_context {
        option.Some(existing_context) -> existing_context
        option.None -> nested_context
      }
    }),
  )
}

/// Adds nested contexts to the current context instance.
pub fn add_contexts(
  context: Context,
  contexts: List(#(reference.Definition, Context)),
) -> Context {
  list.fold(contexts, context, fn(context, entry) {
    let #(definition, nested_context) = entry
    add_context(context, definition, nested_context)
  })
}

/// Gets the next stable binding reference.
pub fn next_binding(context: Context) -> reference.Binding {
  reference.Binding(dict.size(context.bindings))
}

/// Gets the next stable definition reference.
pub fn next_definition(context: Context) -> reference.Definition {
  reference.Definition(dict.size(context.definitions))
}

/// Gets the next stable edge reference.
pub fn next_edge(context: Context) -> reference.Edge {
  reference.Edge(dict.size(context.edges))
}

/// Gets the next stable input reference.
pub fn next_input(context: Context) -> reference.Input {
  reference.Input(dict.size(context.inputs))
}

/// Gets the next stable output reference.
pub fn next_output(context: Context) -> reference.Output {
  reference.Output(dict.size(context.outputs))
}

/// Looks up a typed input by path.
pub fn get_input(
  context: Context,
  path: List(String),
) -> Result(#(reference.Input, reference.Typename), Nil) {
  dict.get(context.inputs, path)
}

/// Looks up a typed output by path.
pub fn get_output(
  context: Context,
  path: List(String),
) -> Result(#(reference.Output, reference.Typename), Nil) {
  dict.get(context.outputs, path)
}

/// Gets the next stable parameter reference.
pub fn next_parameter(context: Context) -> reference.Parameter {
  reference.Parameter(dict.size(context.parameters))
}

/// Gets the next stable return reference.
pub fn next_return(context: Context) -> reference.Return {
  reference.Return(dict.size(context.returns))
}

/// Looks up a binding reference by name.
pub fn get_binding(
  context: Context,
  binding: String,
) -> Result(reference.Binding, Nil) {
  dict.get(context.bindings, binding)
}

/// Looks up a definition reference by name.
pub fn get_definition(
  context: Context,
  definition: String,
) -> Result(reference.Definition, Nil) {
  dict.get(context.definitions, definition)
}

/// Looks up an edge reference by input reference.
pub fn get_edge(
  context: Context,
  input: reference.Input,
) -> Result(reference.Edge, Nil) {
  dict.get(context.edges, input)
}

/// Looks up a parameter reference by name.
pub fn get_parameter(
  context: Context,
  parameter: String,
) -> Result(reference.Parameter, Nil) {
  dict.get(context.parameters, parameter)
}

/// Looks up a return reference by name.
pub fn get_return(
  context: Context,
  return: String,
) -> Result(reference.Return, Nil) {
  dict.get(context.returns, return)
}

/// Looks up a nested context by definition reference.
pub fn get_context(
  context: Context,
  definition: reference.Definition,
) -> Result(Context, Nil) {
  dict.get(context.contexts, definition)
}
