/// A lowered WebQL graph without compiler metadata.
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
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

/// A named access point into a collection of nodes or values.
pub type Boundary {
  Boundary(name: String, from: From, to: List(String))
}

/// A named executable node or nested graph.
pub type Node {
  Node(name: String, path: List(String))
  Supernode(name: String, graph: Graph)
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
