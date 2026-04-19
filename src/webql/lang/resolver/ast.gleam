import webql/lang/resolver/reference
import webql/lang/source

/// The root container for a single top-level operation.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Module {
  Module(operation: Operation, reference: reference.Module, span: source.Span)
}

/// An executable graph with declared interfaces and a body of nested
/// definitions, local bindings, and edges.
///
/// ## Examples
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
/// ## Examples
///
///     in: Int
pub type Parameter {
  Parameter(
    name: String,
    typename: Typename,
    reference: reference.Parameter,
    span: source.Span,
  )
}

/// A declared outgoing interface on an operation.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(
    name: String,
    typename: Typename,
    reference: reference.Return,
    span: source.Span,
  )
}

/// A type annotation describing a value.
///
/// ## Examples
///
///     Int
pub type Typename {
  Typename(name: String, reference: reference.Typename, span: source.Span)
}

/// A named nested operation defined inside another operation.
///
/// ## Examples
///
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Definition {
  Definition(
    name: String,
    operation: Operation,
    reference: reference.Definition,
    span: source.Span,
  )
}

/// A named binding that assigns a value to a local name.
///
/// ## Examples
///
///     m = Math
pub type Binding {
  Binding(
    name: String,
    value: Value,
    reference: reference.Binding,
    span: source.Span,
  )
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Examples
///
///     m.out -> .out
pub type Edge {
  Edge(from: Output, to: Input, reference: reference.Edge, span: source.Span)
}

/// A value used in a binding.
///
/// ## Examples
///
///     Math
///     "hello"
pub type Value {
  NodeValue(name: String, reference: reference.Node, span: source.Span)
  PrimitiveValue(
    value: Primitive,
    typename: reference.Typename,
    span: source.Span,
  )
}

/// A location that can receive data from an edge.
///
/// ## Examples
///
///     .in
///     m.l
pub type Input {
  PortInput(path: List(String), reference: reference.Input, span: source.Span)
}

/// A value that can produce data into an edge.
///
/// ## Examples
///
///     .out
///     m.out
///     "hello"
///     1
pub type Output {
  PortOutput(path: List(String), reference: reference.Output, span: source.Span)
  PrimitiveOutput(
    value: Primitive,
    typename: reference.Typename,
    span: source.Span,
  )
}

/// A literal value embedded in the graph.
///
/// ## Examples
///
///     123
pub type Primitive {
  Int(value: Int, span: source.Span)
  Float(value: Float, span: source.Span)
  String(value: String, span: source.Span)
}
