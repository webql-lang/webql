import gleam/list
import webql/compiler/resolver_1
import webql/graph_1

/// Lowers a resolved syntax tree into a graph.
pub fn lower(ast: resolver_1.Ast) -> graph_1.Graph {
  graph_1.Graph(
    parameters: list.map(ast.parameters, lower_parameter),
    returns: list.map(ast.returns, lower_return),
    supernodes: list.map(ast.supernodes, lower_supernode),
    boundaries: list.map(ast.boundaries, lower_boundary),
    nodes: list.map(ast.nodes, lower_node),
    edges: list.map(ast.edges, lower_edge),
  )
}

// PRIVATE FUNCTIONS
// =================
fn lower_parameter(parameter: resolver_1.Parameter) -> graph_1.Parameter {
  graph_1.Parameter(
    name: parameter.name,
    typename: lower_typename(parameter.typename),
  )
}

fn lower_return(return: resolver_1.Return) -> graph_1.Return {
  graph_1.Return(name: return.name, typename: lower_typename(return.typename))
}

fn lower_typename(typename: resolver_1.Typename) -> graph_1.Typename {
  graph_1.Typename(typename.name)
}

fn lower_supernode(supernode: resolver_1.Supernode) -> graph_1.Supernode {
  graph_1.Supernode(name: supernode.name, graph: lower(supernode.ast))
}

fn lower_boundary(boundary: resolver_1.Boundary) -> graph_1.Boundary {
  graph_1.Boundary(
    name: boundary.name,
    from: lower_from(boundary.from),
    owner: boundary.owner,
    boundary: boundary.boundary,
  )
}

fn lower_node(node: resolver_1.Node) -> graph_1.Node {
  graph_1.Node(name: node.name, owner: node.owner, node: node.node)
}

fn lower_edge(edge: resolver_1.Edge) -> graph_1.Edge {
  graph_1.Edge(from: lower_from(edge.from), to: lower_to(edge.to))
}

fn lower_to(to: resolver_1.To) -> graph_1.To {
  let resolver_1.Input(path:, ..) = to
  graph_1.Input(path: lower_path(path))
}

fn lower_from(from: resolver_1.From) -> graph_1.From {
  case from {
    resolver_1.Output(path:, ..) -> graph_1.Output(path: lower_path(path))
    resolver_1.Literal(value:, ..) -> graph_1.Literal(value: lower_value(value))
  }
}

fn lower_path(path: resolver_1.Path) -> graph_1.Path {
  case path {
    resolver_1.Port(name) -> graph_1.Port(name:)
    resolver_1.Vertex(owner, name) -> graph_1.Vertex(owner:, name:)
  }
}

fn lower_value(value: resolver_1.Value) -> graph_1.Value {
  case value {
    resolver_1.Int(value, ..) -> graph_1.Int(value)
    resolver_1.Float(value, ..) -> graph_1.Float(value)
    resolver_1.String(value, ..) -> graph_1.String(value)
  }
}
