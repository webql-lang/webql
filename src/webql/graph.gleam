import gleam/option

/// A lowered WebQL graph without compiler metadata.
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
    supernodes: List(Supernode),
    boundaries: List(Boundary),
    nodes: List(Node),
    edges: List(Edge),
  )
}

/// A value supplied by the caller and used on the left side of an edge.
pub type Parameter {
  Parameter(name: String, typename: Typename)
}

/// A value produced by the graph and returned through the right side of an edge.
pub type Return {
  Return(name: String, typename: Typename)
}

/// A declared parameter or return type.
pub type Typename {
  Typename(name: String)
}

/// A reusable graph declared inside another graph.
pub type Supernode {
  Supernode(name: String, graph: Graph)
}

/// An instantiated boundary.
pub type Boundary {
  Boundary(
    name: String,
    from: From,
    owner: option.Option(String),
    boundary: String,
  )
}

/// An executable node instance.
pub type Node {
  Node(name: String, owner: option.Option(String), node: String)
}

/// A directed connection from a value to an input.
pub type Edge {
  Edge(from: From, to: To)
}

/// A graph-interface port or node or boundary vertex.
pub type Path {
  Port(name: String)
  Vertex(owner: String, name: String)
}

/// A value on the left side of an arrow.
pub type From {
  Output(path: Path)
  Literal(value: Value)
}

/// An input on the right side of an arrow.
pub type To {
  Input(path: Path)
}

/// A literal embedded directly in the graph.
pub type Value {
  Int(value: Int)
  Float(value: Float)
  String(value: String)
}
