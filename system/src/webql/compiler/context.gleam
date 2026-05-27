import gleam/dict
import gleam/list
import gleam/option
import webql/compiler/reference

pub type Context {
  Context(
    nodes: dict.Dict(String, reference.Node),
    supernodes: dict.Dict(String, reference.Supernode),
    edges: dict.Dict(reference.Input, reference.Edge),
    inputs: dict.Dict(List(String), #(reference.Input, reference.Port)),
    outputs: dict.Dict(List(String), #(reference.Output, reference.Port)),
    parameters: dict.Dict(String, reference.Parameter),
    returns: dict.Dict(String, reference.Return),
    contexts: dict.Dict(reference.Supernode, Context),
  )
}

/// Creates a new context.
pub fn new() -> Context {
  Context(
    nodes: dict.new(),
    supernodes: dict.new(),
    edges: dict.new(),
    inputs: dict.new(),
    outputs: dict.new(),
    parameters: dict.new(),
    returns: dict.new(),
    contexts: dict.new(),
  )
}

/// Adds a node to the current context instance.
pub fn add_node(context: Context, node: String) -> Context {
  let Context(nodes:, ..) = context

  Context(
    ..context,
    nodes: dict.upsert(nodes, node, fn(node) {
      case node {
        option.Some(node) -> node
        option.None -> next_node(context)
      }
    }),
  )
}

/// Adds nodes to the current context instance.
pub fn add_nodes(context: Context, nodes: List(String)) -> Context {
  list.fold(nodes, context, add_node)
}

/// Adds a supernode to the current context instance.
pub fn add_supernode(context: Context, supernode: String) -> Context {
  let Context(supernodes:, ..) = context

  Context(
    ..context,
    supernodes: dict.upsert(supernodes, supernode, fn(supernode) {
      case supernode {
        option.Some(supernode) -> supernode
        option.None -> next_supernode(context)
      }
    }),
  )
}

/// Adds supernodes to the current context instance.
pub fn add_supernodes(context: Context, supernodes: List(String)) -> Context {
  list.fold(supernodes, context, add_supernode)
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
  port: reference.Port,
) -> Context {
  let Context(inputs:, ..) = context

  Context(
    ..context,
    inputs: dict.upsert(inputs, input, fn(input) {
      case input {
        option.Some(input) -> input
        option.None -> #(next_input(context), port)
      }
    }),
  )
}

/// Adds typed inputs to the current context instance.
pub fn add_inputs(
  context: Context,
  inputs: List(#(List(String), reference.Port)),
) -> Context {
  list.fold(inputs, context, fn(context, input) {
    let #(path, port) = input
    add_input(context, path, port)
  })
}

/// Adds a typed output to the current context instance.
pub fn add_output(
  context: Context,
  output: List(String),
  port: reference.Port,
) -> Context {
  let Context(outputs:, ..) = context

  Context(
    ..context,
    outputs: dict.upsert(outputs, output, fn(output) {
      case output {
        option.Some(output) -> output
        option.None -> #(next_output(context), port)
      }
    }),
  )
}

/// Adds typed outputs to the current context instance.
pub fn add_outputs(
  context: Context,
  outputs: List(#(List(String), reference.Port)),
) -> Context {
  list.fold(outputs, context, fn(context, output) {
    let #(path, port) = output
    add_output(context, path, port)
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
  supernode: reference.Supernode,
  nested_context: Context,
) -> Context {
  let Context(contexts:, ..) = context

  Context(
    ..context,
    contexts: dict.upsert(contexts, supernode, fn(existing_context) {
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
  contexts: List(#(reference.Supernode, Context)),
) -> Context {
  list.fold(contexts, context, fn(context, entry) {
    let #(supernode, nested_context) = entry
    add_context(context, supernode, nested_context)
  })
}

/// Gets the next stable node reference.
pub fn next_node(context: Context) -> reference.Node {
  reference.Node(dict.size(context.nodes))
}

/// Gets the next stable supernode reference.
pub fn next_supernode(context: Context) -> reference.Supernode {
  reference.Supernode(dict.size(context.supernodes))
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
) -> Result(#(reference.Input, reference.Port), Nil) {
  dict.get(context.inputs, path)
}

/// Looks up a typed output by path.
pub fn get_output(
  context: Context,
  path: List(String),
) -> Result(#(reference.Output, reference.Port), Nil) {
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

/// Looks up a node reference by name.
pub fn get_node(context: Context, node: String) -> Result(reference.Node, Nil) {
  dict.get(context.nodes, node)
}

/// Looks up a supernode reference by name.
pub fn get_supernode(
  context: Context,
  supernode: String,
) -> Result(reference.Supernode, Nil) {
  dict.get(context.supernodes, supernode)
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

/// Looks up a nested context by supernode reference.
pub fn get_context(
  context: Context,
  supernode: reference.Supernode,
) -> Result(Context, Nil) {
  dict.get(context.contexts, supernode)
}
