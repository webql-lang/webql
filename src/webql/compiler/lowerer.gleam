import gleam/list
import webql/compiler/resolver
import webql/graph

pub opaque type Lowerer {
  Lowerer(document: resolver.Document)
}

/// Creates a new lowerer instance from a resolver document.
pub fn new(document: resolver.Document) -> Lowerer {
  Lowerer(document:)
}

/// Lowers a resolver document into compiler IR.
pub fn lower(lowerer: Lowerer) -> graph.Graph {
  lower_document(lowerer.document)
}

// PRIVATE FUNCTIONS
// =================
fn lower_document(document: resolver.Document) -> graph.Graph {
  lower_graph(document.graph)
}

fn lower_graph(graph: resolver.Graph) -> graph.Graph {
  let supernodes = lower_supernodes(graph.nodes)

  graph.Graph(
    parameters: list.map(graph.parameters, lower_parameter),
    returns: list.map(graph.returns, lower_return),
    nodes: lower_nodes(graph.nodes, supernodes),
    edges: list.map(graph.edges, lower_edge),
  )
}

fn lower_supernodes(
  nodes: List(resolver.Node),
) -> List(#(String, graph.Graph)) {
  case nodes {
    [resolver.Supernode(name:, graph:, ..), ..nodes] -> [
      #(name, lower_graph(graph)),
      ..lower_supernodes(nodes)
    ]

    [resolver.Node(..), ..nodes] -> lower_supernodes(nodes)
    [] -> []
  }
}

fn lower_nodes(
  nodes: List(resolver.Node),
  supernodes: List(#(String, graph.Graph)),
) -> List(graph.Node) {
  case nodes {
    [resolver.Supernode(..), ..nodes] -> lower_nodes(nodes, supernodes)

    [resolver.Node(name:, node:, ..), ..nodes] -> {
      let node = lower_node(name, node, supernodes)
      [node, ..lower_nodes(nodes, supernodes)]
    }

    [] -> []
  }
}

fn lower_node(
  name: String,
  node: String,
  supernodes: List(#(String, graph.Graph)),
) -> graph.Node {
  case supernodes {
    [#(supernode, graph), ..] if supernode == node ->
      graph.Supernode(name:, graph:)

    [_supernode, ..supernodes] -> lower_node(name, node, supernodes)
    [] -> graph.Node(name:, node:)
  }
}

fn lower_parameter(parameter: resolver.Parameter) -> graph.Parameter {
  graph.Parameter(name: parameter.name, port: parameter.port.name)
}

fn lower_return(return: resolver.Return) -> graph.Return {
  graph.Return(name: return.name, port: return.port.name)
}

fn lower_edge(edge: resolver.Edge) -> graph.Edge {
  graph.Edge(
    source: lower_source(edge.source),
    target: lower_target(edge.target),
  )
}

fn lower_source(source: resolver.Source) -> graph.Source {
  case source {
    resolver.Output(path:, ..) -> graph.Output(path:)
    resolver.Literal(value:, ..) -> graph.Literal(value: lower_value(value))
  }
}

fn lower_target(target: resolver.Target) -> graph.Target {
  graph.Input(path: target.path)
}

fn lower_value(value: resolver.Value) -> graph.Value {
  case value {
    resolver.Int(value:, ..) -> graph.Int(value:)
    resolver.Float(value:, ..) -> graph.Float(value:)
    resolver.String(value:, ..) -> graph.String(value:)
  }
}
