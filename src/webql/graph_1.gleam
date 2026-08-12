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
  Parameter(name: String, port: Port)
}

/// A value produced by the graph and returned through the right side of an edge.
pub type Return {
  Return(name: String, port: Port)
}

/// A declared parameter or return type.
pub type Port {
  Port(name: String)
}

/// A named graph nested inside another graph.
pub type Supernode {
  Supernode(name: String, graph: Graph)
}

/// A labeled connection into a node.
pub type Boundary {
  Boundary(name: String, from: From, to: List(String))
}

/// A named node.
pub type Node {
  Node(name: String, path: List(String))
}

/// A directed connection from an output or literal to an input.
pub type Edge {
  Edge(from: From, to: Input)
}

/// A destination that receives an edge.
pub type Input {
  Input(path: List(String))
}

/// An output or literal on the left side of an arrow.
pub type From {
  Output(path: List(String))
  Literal(value: Value)
}

/// A literal embedded directly in the graph.
pub type Value {
  Int(Int)
  Float(Float)
  String(String)
}
