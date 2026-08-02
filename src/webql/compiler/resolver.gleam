import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/source

/// The root container for a single top-level graph.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Document {
  Document(graph: Graph, reference: reference.Document, span: source.Span)
}

/// An executable graph with declared interfaces, nested supernodes, local
/// nodes, and edges.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
    nodes: List(Node),
    edges: List(Edge),
    span: source.Span,
  )
}

/// A declared incoming interface on a graph.
///
/// ## Examples
///
///     in: Int
pub type Parameter {
  Parameter(
    name: String,
    port: Port,
    reference: reference.Parameter,
    span: source.Span,
  )
}

/// A declared outgoing interface on a graph.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(
    name: String,
    port: Port,
    reference: reference.Return,
    span: source.Span,
  )
}

/// A port annotation describing a value.
///
/// ## Examples
///
///     Int
pub type Port {
  Port(name: String, reference: reference.Port, span: source.Span)
}

/// A named nested graph defined inside another graph.
///
/// ## Examples
///
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Node {
  Supernode(
    name: String,
    graph: Graph,
    reference: reference.Supernode,
    span: source.Span,
  )
  Node(name: String, node: String, reference: reference.Node, span: source.Span)
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Examples
///
///     m.out -> .out
pub type Edge {
  Edge(
    source: Source,
    target: Target,
    reference: reference.Edge,
    span: source.Span,
  )
}

/// A location that can receive data from an edge.
///
/// ## Examples
///
///     .in
///     m.l
pub type Target {
  Input(path: List(String), reference: reference.Input, span: source.Span)
}

/// A value that can produce data into an edge.
///
/// ## Examples
///
///     .out
///     m.out
///     "hello"
///     1
pub type Source {
  Output(path: List(String), reference: reference.Output, span: source.Span)
  Literal(value: Value, port: reference.Port, span: source.Span)
}

/// A literal value embedded in the graph.
///
/// ## Examples
///
///     123
pub type Value {
  Int(name: String, value: Int, span: source.Span)
  Float(name: String, value: Float, span: source.Span)
  String(name: String, value: String, span: source.Span)
}

pub type DiagnosticKind {
  UnknownPort(name: String)
  UnknownNode(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateReturn(name: String)
  DuplicateParameter(name: String)
  DuplicateSupernode(name: String)
  DuplicateNode(name: String)
  DuplicateEdgeInput(path: List(String))
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// Resolves an AST into a HIR.
pub fn resolve(
  document: parser.Document,
  environment: environment.Environment,
  context: context.Context,
) -> Result(#(Document, context.Context), Diagnostic) {
  let reference = reference.Document(0)
  resolve_document(environment, context, document, reference)
}

fn resolve_document(
  environment: environment.Environment,
  context: context.Context,
  document: parser.Document,
  reference: reference.Document,
) -> Result(#(Document, context.Context), Diagnostic) {
  use #(graph, context) <- result.try(resolve_graph(
    environment,
    context,
    document.graph,
  ))

  Ok(#(Document(graph:, reference:, span: document.span), context))
}

fn resolve_graph(
  environment: environment.Environment,
  context: context.Context,
  graph: parser.Graph,
) -> Result(#(Graph, context.Context), Diagnostic) {
  use #(graph, context, _environment) <- result.try(resolve_body(
    environment,
    context,
    graph,
  ))
  Ok(#(graph, context))
}

fn resolve_body(
  environment: environment.Environment,
  context: context.Context,
  graph: parser.Graph,
) -> Result(#(Graph, context.Context, environment.Environment), Diagnostic) {
  let parser.Graph(parameters:, returns:, nodes:, edges:, span:) = graph

  use #(parameters, context) <- result.try(resolve_parameters(
    environment,
    context,
    parameters,
  ))

  use #(returns, context) <- result.try(resolve_returns(
    environment,
    context,
    returns,
  ))

  use #(supernodes, context, environment) <- result.try(resolve_supernodes(
    environment,
    context,
    nodes,
  ))

  use #(nodes, context) <- result.try(resolve_nodes(environment, context, nodes))

  use #(edges, context) <- result.try(resolve_edges(environment, context, edges))

  let nodes = list.append(supernodes, nodes)

  Ok(#(
    Graph(parameters:, returns:, nodes:, edges:, span:),
    context,
    environment,
  ))
}

fn resolve_parameters(
  environment: environment.Environment,
  context: context.Context,
  parameters: List(parser.Parameter),
) {
  case parameters {
    [parameter, ..rest] -> {
      let reference = context.next_parameter(context)

      use parameter <- result.try(resolve_parameter(
        environment,
        context,
        parameter,
        reference,
      ))

      let context = register_parameter(context, parameter)

      use #(rest, context) <- result.try(resolve_parameters(
        environment,
        context,
        rest,
      ))
      Ok(#([parameter, ..rest], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_returns(
  environment: environment.Environment,
  context: context.Context,
  returns: List(parser.Return),
) {
  case returns {
    [return, ..rest] -> {
      let reference = context.next_return(context)

      use return <- result.try(resolve_return(
        environment,
        context,
        return,
        reference,
      ))

      let context = register_return(context, return)

      use #(rest, context) <- result.try(resolve_returns(
        environment,
        context,
        rest,
      ))
      Ok(#([return, ..rest], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_supernodes(
  environment: environment.Environment,
  context: context.Context,
  nodes: List(parser.Node),
) -> Result(#(List(Node), context.Context, environment.Environment), Diagnostic) {
  case nodes {
    [parser.Supernode(..) as supernode, ..nodes] -> {
      use #(supernode, context, environment) <- result.try(resolve_node(
        environment,
        context,
        supernode,
      ))

      use #(nodes, context, environment) <- result.try(resolve_supernodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([supernode, ..nodes], context, environment))
    }

    [parser.Node(..), ..nodes] ->
      resolve_supernodes(environment, context, nodes)

    [] -> Ok(#([], context, environment))
  }
}

fn resolve_nodes(
  environment: environment.Environment,
  context: context.Context,
  nodes: List(parser.Node),
) {
  case nodes {
    [parser.Node(..) as node, ..nodes] -> {
      use #(node, context, _environment) <- result.try(resolve_node(
        environment,
        context,
        node,
      ))

      use #(nodes, context) <- result.try(resolve_nodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([node, ..nodes], context))
    }

    [parser.Supernode(..), ..nodes] ->
      resolve_nodes(environment, context, nodes)

    [] -> Ok(#([], context))
  }
}

fn resolve_edges(
  environment: environment.Environment,
  context: context.Context,
  edges: List(parser.Edge),
) {
  case edges {
    [edge, ..edges] -> {
      let reference = context.next_edge(context)
      use edge <- result.try(resolve_edge(environment, context, edge, reference))

      let context = register_edge(context, edge)

      use #(edges, context) <- result.try(resolve_edges(
        environment,
        context,
        edges,
      ))
      Ok(#([edge, ..edges], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_parameter(
  environment: environment.Environment,
  context: context.Context,
  field: parser.Parameter,
  reference: reference.Parameter,
) -> Result(Parameter, Diagnostic) {
  let parser.Parameter(name:, port:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_parameter(context, name)),
    return: Error(Diagnostic(kind: DuplicateParameter(name), span:)),
  )

  use port <- result.try(resolve_port(environment, port))

  Ok(Parameter(name:, port:, reference:, span:))
}

fn register_parameter(
  context: context.Context,
  parameter: Parameter,
) -> context.Context {
  context
  |> context.add_parameter(parameter.name)
  |> context.add_output([parameter.name], parameter.port.reference)
}

fn resolve_return(
  environment: environment.Environment,
  context: context.Context,
  field: parser.Return,
  reference: reference.Return,
) -> Result(Return, Diagnostic) {
  let parser.Return(name:, port:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_return(context, name)),
    return: Error(Diagnostic(kind: DuplicateReturn(name), span:)),
  )

  use port <- result.try(resolve_port(environment, port))

  Ok(Return(name:, port:, reference:, span:))
}

fn register_return(
  context: context.Context,
  return: Return,
) -> context.Context {
  context
  |> context.add_return(return.name)
  |> context.add_input([return.name], return.port.reference)
}

fn resolve_port(
  environment: environment.Environment,
  port: parser.Port,
) -> Result(Port, Diagnostic) {
  case environment.get_port(environment, port.name) {
    Ok(reference) -> Ok(Port(name: port.name, reference:, span: port.span))

    Error(_nil) ->
      Error(Diagnostic(kind: UnknownPort(port.name), span: port.span))
  }
}

fn resolve_node(
  environment: environment.Environment,
  context: context.Context,
  node: parser.Node,
) -> Result(#(Node, context.Context, environment.Environment), Diagnostic) {
  case node {
    parser.Node(name:, node:, span:) ->
      resolve_node_from(environment, context, name, node, span)

    parser.Supernode(name:, graph:, span:) ->
      resolve_supernode(environment, context, name, graph, span)
  }
}

fn resolve_node_from(
  environment: environment.Environment,
  context: context.Context,
  name: String,
  node: String,
  span: source.Span,
) {
  use <- bool.guard(
    when: result.is_ok(context.get_node(context, name)),
    return: Error(Diagnostic(kind: DuplicateNode(name), span:)),
  )

  case environment.get_node(environment, node) {
    Ok(_reference) -> {
      let reference = context.next_node(context)
      let node = Node(name:, node:, reference:, span:)
      let context = register_node(environment, context, node)

      Ok(#(node, context, environment))
    }

    Error(_nil) -> Error(Diagnostic(kind: UnknownNode(node), span:))
  }
}

fn resolve_supernode(
  environment: environment.Environment,
  context: context.Context,
  name: String,
  graph: parser.Graph,
  span: source.Span,
) -> Result(#(Node, context.Context, environment.Environment), Diagnostic) {
  use <- bool.guard(
    when: result.is_ok(environment.get_node(environment, name)),
    return: Error(Diagnostic(kind: DuplicateSupernode(name), span:)),
  )

  let reference = context.next_supernode(context)

  use #(graph, sub_context) <- result.try(resolve_graph(
    environment,
    context.Context(
      ..context,
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      nodes: dict.new(),
      edges: dict.new(),
    ),
    graph,
  ))

  let supernode = Supernode(name:, graph:, reference:, span:)
  let context = register_supernode(context, name, reference, sub_context)
  let environment = register_supernode_ports(environment, name, graph)

  Ok(#(supernode, context, environment))
}

fn register_supernode(
  context: context.Context,
  name: String,
  reference: reference.Supernode,
  sub_context: context.Context,
) -> context.Context {
  context
  |> context.add_supernode(name)
  |> context.add_context(reference, sub_context)
}

fn register_supernode_ports(
  environment: environment.Environment,
  name: String,
  graph: Graph,
) -> environment.Environment {
  let node = environment.next_node(environment)
  let environment = environment.add_node(environment, name)

  let environment =
    list.fold(graph.parameters, environment, fn(environment, parameter) {
      environment.add_input(environment, node, #(
        parameter.name,
        parameter.port.reference,
      ))
    })

  list.fold(graph.returns, environment, fn(environment, return) {
    environment.add_output(environment, node, #(
      return.name,
      return.port.reference,
    ))
  })
}

fn register_node(
  environment: environment.Environment,
  context: context.Context,
  node: Node,
) -> context.Context {
  let context = context.add_node(context, node.name)

  case node {
    Node(name:, node:, ..) -> {
      case environment.get_node(environment, node) {
        Ok(reference) ->
          register_node_ports(context, environment, name, reference)

        Error(_nil) -> context
      }
    }

    Supernode(..) -> context
  }
}

fn register_node_ports(
  context: context.Context,
  environment: environment.Environment,
  name: String,
  node: reference.Node,
) {
  let context = case environment.get_inputs(environment, node) {
    Ok(inputs) -> register_inputs(context, name, inputs)
    Error(_nil) -> context
  }

  case environment.get_outputs(environment, node) {
    Ok(outputs) -> register_outputs(context, name, outputs)
    Error(_nil) -> context
  }
}

fn register_inputs(
  context: context.Context,
  name: String,
  inputs: List(#(String, reference.Port)),
) {
  list.fold(inputs, context, fn(context, input) {
    let #(port, reference) = input
    context.add_input(context, [name, port], reference)
  })
}

fn register_outputs(
  context: context.Context,
  name: String,
  outputs: List(#(String, reference.Port)),
) {
  list.fold(outputs, context, fn(context, output) {
    let #(port, reference) = output
    context.add_output(context, [name, port], reference)
  })
}

fn resolve_edge(
  environment: environment.Environment,
  context: context.Context,
  edge: parser.Edge,
  reference: reference.Edge,
) -> Result(Edge, Diagnostic) {
  let parser.Edge(source:, target:, span:) = edge

  use source <- result.try(resolve_source(environment, context, source))
  use target <- result.try(resolve_target(context, target))

  use <- bool.guard(
    when: result.is_ok(context.get_edge(context, target.reference)),
    return: Error(Diagnostic(kind: DuplicateEdgeInput(target.path), span:)),
  )

  Ok(Edge(source:, target:, reference:, span:))
}

fn register_edge(context: context.Context, edge: Edge) -> context.Context {
  context.add_edge(context, edge.target.reference)
}

fn resolve_source(
  environment: environment.Environment,
  context: context.Context,
  source: parser.Source,
) -> Result(Source, Diagnostic) {
  case source {
    parser.Output(path:, span:) -> resolve_output(context, path, span)

    parser.Literal(value:, span:) -> resolve_literal(environment, value, span)
  }
}

fn resolve_output(
  context: context.Context,
  path: List(String),
  span: source.Span,
) {
  case context.get_output(context, path) {
    Ok(#(reference, _port)) -> Ok(Output(path:, reference:, span:))

    Error(_nil) -> Error(Diagnostic(kind: UnknownOutput(path), span:))
  }
}

fn resolve_literal(
  environment: environment.Environment,
  value: parser.Value,
  span: source.Span,
) {
  case environment.get_port(environment, value.name) {
    Ok(port) -> {
      let value = resolve_value(value)
      Ok(Literal(value:, port:, span:))
    }

    Error(_nil) -> Error(Diagnostic(kind: UnknownPort(value.name), span:))
  }
}

fn resolve_target(
  context: context.Context,
  target: parser.Target,
) -> Result(Target, Diagnostic) {
  let parser.Input(path:, span:) = target

  case context.get_input(context, path) {
    Ok(#(reference, _port)) -> Ok(Input(path:, reference:, span:))

    Error(_nil) -> Error(Diagnostic(kind: UnknownInput(path), span:))
  }
}

fn resolve_value(value: parser.Value) -> Value {
  case value {
    parser.Int(name:, value:, span:) -> Int(name:, value:, span:)
    parser.Float(name:, value:, span:) -> Float(name:, value:, span:)
    parser.String(name:, value:, span:) -> String(name:, value:, span:)
  }
}
