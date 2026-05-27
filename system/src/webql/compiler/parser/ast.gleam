import webql/compiler/source

/// The root container for a single top-level graph.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Document {
  Document(graph: Graph, span: source.Span)
}

/// An executable graph with declared interfaces, nested supernodes, local
/// nodes, and edges.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
    nodes: List(Node),
    edges: List(Edge),
    span: source.Span,
  )
}

/// A declared incoming interface on a graph.
///
/// ## Examples
///
///     in: Int
pub type Parameter {
  Parameter(name: String, port: Port, span: source.Span)
}

/// A declared outgoing interface on a graph.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(name: String, port: Port, span: source.Span)
}

/// A port annotation describing a value.
///
/// ## Examples
///
///     Int
pub type Port {
  Port(name: String, span: source.Span)
}

/// A named nested graph defined inside another graph.
///
/// ## Examples
///
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Node {
  Supernode(name: String, graph: Graph, span: source.Span)
  Node(name: String, node: String, span: source.Span)
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Examples
///
///     m.out -> .out
pub type Edge {
  Edge(source: Source, target: Target, span: source.Span)
}

/// A location that can receive data from an edge.
///
/// ## Examples
///
///     .in
///     m.l
pub type Target {
  Input(path: List(String), span: source.Span)
}

/// A value that can produce data into an edge.
///
/// ## Examples
///
///     .out
///     m.out
///     1
pub type Source {
  Output(path: List(String), span: source.Span)
  Literal(value: Value, span: source.Span)
}

/// A literal value embedded in the graph.
///
/// ## Examples
///
///     123
///     1.23
///     "hello"
pub type Value {
  Int(name: String, value: Int, span: source.Span)
  Float(name: String, value: Float, span: source.Span)
  String(name: String, value: String, span: source.Span)
}
