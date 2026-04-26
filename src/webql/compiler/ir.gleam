/// The root container for a single lowered top-level operation.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Module {
  Module(operation: Operation)
}

/// A lowered executable graph with declared interfaces, node instances, and
/// edges between concrete ports.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Operation {
  Operation(
    inputs: List(Parameter),
    outputs: List(Return),
    nodes: List(Node),
    edges: List(Edge),
  )
}

/// A declared incoming interface on an operation.
///
/// ## Examples
///
///     in: Int
pub type Parameter {
  Parameter(name: String, typename: String)
}

/// A declared outgoing interface on an operation.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(name: String, typename: String)
}

/// A node inside an operation.
///
/// ## Examples
///
///     m = Math
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Node {
  ExternalNode(name: String, node: String)
  InlineNode(name: String, operation: Operation)
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Examples
///
///     m.out -> .out
pub type Edge {
  Edge(from: Output, to: Input)
}

/// A location that can receive data from an edge.
///
/// ## Examples
///
///     .in
///     m.l
pub type Input {
  Input(path: List(String))
}

/// A value that can produce data into an edge.
///
/// ## Examples
///
///     .out
///     m.out
///     1
pub type Output {
  Output(path: List(String))
  PrimitiveOutput(value: Primitive)
}

/// A literal value embedded in the graph.
///
/// ## Examples
///
///     123
///     1.23
///     "hello"
pub type Primitive {
  IntPrimitive(value: Int)
  FloatPrimitive(value: Float)
  StringPrimitive(value: String)
}
