import gleam/list
import webql/compiler/resolver_1
import webql/graph_1

/// Lowers a resolved syntax tree into a graph.
pub fn lower(ast: resolver_1.Ast) -> graph_1.Graph {
  let resolver_1.Ast(
    parameters:,
    returns:,
    supernodes:,
    boundaries:,
    nodes:,
    edges:,
    ..,
  ) = ast

  graph_1.Graph(
    parameters: list.map(parameters, lower_parameter),
    returns: list.map(returns, lower_return),
    supernodes: list.map(supernodes, lower_supernode),
    boundaries: list.map(boundaries, lower_boundary),
    nodes: list.map(nodes, lower_node),
    edges: list.map(edges, lower_edge),
  )
}

fn lower_parameter(parameter: resolver_1.Parameter) -> graph_1.Parameter {
  graph_1.Parameter(name: parameter.name, port: lower_port(parameter.port))
}

fn lower_return(return: resolver_1.Return) -> graph_1.Return {
  graph_1.Return(name: return.name, port: lower_port(return.port))
}

fn lower_port(port: resolver_1.Port) -> graph_1.Port {
  graph_1.Port(port.name)
}

fn lower_supernode(supernode: resolver_1.Supernode) -> graph_1.Supernode {
  graph_1.Supernode(name: supernode.name, graph: lower(supernode.ast))
}

fn lower_boundary(boundary: resolver_1.Boundary) -> graph_1.Boundary {
  graph_1.Boundary(
    name: boundary.name,
    from: lower_from(boundary.from),
    to: boundary.to,
  )
}

fn lower_node(node: resolver_1.Node) -> graph_1.Node {
  graph_1.Node(name: node.name, path: node.path)
}

fn lower_edge(edge: resolver_1.Edge) -> graph_1.Edge {
  graph_1.Edge(from: lower_from(edge.from), to: lower_input(edge.to))
}

fn lower_input(input: resolver_1.Input) -> graph_1.Input {
  graph_1.Input(path: input.path)
}

fn lower_from(from: resolver_1.From) -> graph_1.From {
  case from {
    resolver_1.Output(path:, ..) -> graph_1.Output(path:)

    resolver_1.Literal(value:, ..) -> graph_1.Literal(value: lower_value(value))
  }
}

fn lower_value(value: resolver_1.Value) -> graph_1.Value {
  case value {
    resolver_1.Int(value, ..) -> graph_1.Int(value)
    resolver_1.Float(value, ..) -> graph_1.Float(value)
    resolver_1.String(value, ..) -> graph_1.String(value)
  }
}
