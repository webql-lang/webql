import gleam/list
import webql/typechecker
import webql/graph
import webql/resolver

/// Lowers a resolved syntax tree into a graph.
pub fn lower(tast: typechecker.Tast) -> graph.Graph {
  graph.Graph(
    parameters: list.map(tast.ast.parameters, lower_parameter),
    returns: list.map(tast.ast.returns, lower_return),
    supernodes: list.map(tast.ast.supernodes, lower_supernode),
    boundaries: list.map(tast.ast.boundaries, lower_boundary),
    nodes: list.map(tast.ast.nodes, lower_node),
    edges: list.map(tast.ast.edges, lower_edge),
  )
}

// PRIVATE FUNCTIONS
// =================
fn lower_parameter(parameter: resolver.Parameter) -> graph.Parameter {
  graph.Parameter(
    name: parameter.name,
    typename: lower_typename(parameter.typename),
  )
}

fn lower_return(return: resolver.Return) -> graph.Return {
  graph.Return(name: return.name, typename: lower_typename(return.typename))
}

fn lower_typename(typename: resolver.Typename) -> graph.Typename {
  graph.Typename(typename.name)
}

fn lower_supernode(supernode: resolver.Supernode) -> graph.Supernode {
  graph.Supernode(
    name: supernode.name,
    graph: lower(typechecker.Tast(supernode.ast)),
  )
}

fn lower_boundary(boundary: resolver.Boundary) -> graph.Boundary {
  graph.Boundary(
    name: boundary.name,
    from: lower_from(boundary.from),
    owner: boundary.owner,
    boundary: boundary.boundary,
  )
}

fn lower_node(node: resolver.Node) -> graph.Node {
  graph.Node(name: node.name, owner: node.owner, node: node.node)
}

fn lower_edge(edge: resolver.Edge) -> graph.Edge {
  graph.Edge(from: lower_from(edge.from), to: lower_to(edge.to))
}

fn lower_to(to: resolver.To) -> graph.To {
  let resolver.Input(path:, ..) = to
  graph.Input(path: lower_path(path))
}

fn lower_from(from: resolver.From) -> graph.From {
  case from {
    resolver.Output(path:, ..) -> graph.Output(path: lower_path(path))
    resolver.Literal(value:, ..) -> graph.Literal(value: lower_value(value))
  }
}

fn lower_path(path: resolver.Path) -> graph.Path {
  case path {
    resolver.Port(name) -> graph.Port(name:)
    resolver.Vertex(owner, name) -> graph.Vertex(owner:, name:)
  }
}

fn lower_value(value: resolver.Value) -> graph.Value {
  case value {
    resolver.Int(value, ..) -> graph.Int(value)
    resolver.Float(value, ..) -> graph.Float(value)
    resolver.String(value, ..) -> graph.String(value)
  }
}
