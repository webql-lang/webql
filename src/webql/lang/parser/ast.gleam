import webql/lang/source

/// The root container for a single top-level operation.
///
/// ## Example
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Module {
  Module(operation: Operation, span: source.Span)
}

/// An executable graph with declared interfaces and a body of nested
/// definitions, local bindings, and edges.
///
/// ## Example
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Operation {
  Operation(
    parameters: List(Parameter),
    returns: List(Return),
    definitions: List(Definition),
    bindings: List(Binding),
    edges: List(Edge),
    span: source.Span,
  )
}

/// A declared incoming interface on an operation.
///
/// ## Example
///
///     in: Int
pub type Parameter {
  Parameter(name: String, typename: Typename, span: source.Span)
}

/// A declared outgoing interface on an operation.
///
/// ## Example
///
///     out: Int
pub type Return {
  Return(name: String, typename: Typename, span: source.Span)
}

/// A type annotation describing a value.
///
/// ## Example
///
///     Int
pub type Typename {
  Typename(name: String, span: source.Span)
}

/// A named nested operation defined inside another operation.
///
/// ## Example
///
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Definition {
  Definition(name: String, operation: Operation, span: source.Span)
}

/// A named binding that assigns a value to a local name.
///
/// ## Example
///
///     m = Math
pub type Binding {
  Binding(name: String, value: Value, span: source.Span)
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Example
///
///     m.out -> .out
pub type Edge {
  Edge(from: Output, to: Input, span: source.Span)
}

/// A value used in a binding.
///
/// ## Example
///
///     Math
///     "hello"
pub type Value {
  NodeValue(name: String, span: source.Span)
  PrimitiveValue(value: Primitive, span: source.Span)
}

/// A location that can receive data from an edge.
///
/// ## Example
///
///     .in
///     m.l
pub type Input {
  PortInput(path: List(String), span: source.Span)
}

/// A value that can produce data into an edge.
///
/// ## Example
///
///     .out
///     m.out
///     1
pub type Output {
  PortOutput(path: List(String), span: source.Span)
  PrimitiveOutput(value: Primitive, span: source.Span)
}

/// A literal value embedded in the graph.
///
/// ## Example
///
///     123
pub type Primitive {
  Int(value: Int, span: source.Span)
  Float(value: Float, span: source.Span)
  String(value: String, span: source.Span)
}
