/// A lowered executable graph with declared interfaces, node instances, and
/// edges between concrete ports.
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
    nodes: List(Node),
    edges: List(Edge),
  )
}

/// A declared incoming interface on a graph.
pub type Parameter {
  Parameter(name: String, port: String)
}

/// A declared outgoing interface on a graph.
pub type Return {
  Return(name: String, port: String)
}

/// A node inside a graph.
pub type Node {
  Supernode(name: String, graph: Graph)
  Node(name: String, node: String)
}

/// A directed connection from a producing value to a receiving location.
pub type Edge {
  Edge(source: Source, target: Target)
}

/// A value that can produce data into an edge.
pub type Source {
  Output(path: List(String))
  Literal(value: Value)
}

/// A location that can receive data from an edge.
pub type Target {
  Input(path: List(String))
}

/// A literal value embedded in the graph.
pub type Value {
  Int(value: Int)
  Float(value: Float)
  String(value: String)
}
