/// The root container for a single lowered top-level operation.
pub type Module {
  Module(operation: Operation)
}

/// A lowered executable graph with declared interfaces, node instances, and
/// edges between concrete ports.
pub type Operation {
  Operation(
    parameters: List(Parameter),
    returns: List(Return),
    nodes: List(Node),
    edges: List(Edge),
  )
}

/// A declared incoming interface on an operation.
pub type Parameter {
  Parameter(name: String, typename: String)
}

/// A declared outgoing interface on an operation.
///
pub type Return {
  Return(name: String, typename: String)
}

/// A node inside an operation.
pub type Node {
  ExternalNode(name: String, node: String)
  InlineNode(name: String, operation: Operation)
}

/// A directed connection from a producing value to a receiving location.
pub type Edge {
  Edge(from: Output, to: Input)
}

/// A location that can receive data from an edge.
pub type Input {
  Input(path: List(String))
}

/// A value that can produce data into an edge.
pub type Output {
  Output(path: List(String))
  PrimitiveOutput(value: Primitive)
}

/// A literal value embedded in the graph.
pub type Primitive {
  IntPrimitive(value: Int)
  FloatPrimitive(value: Float)
  StringPrimitive(value: String)
}
