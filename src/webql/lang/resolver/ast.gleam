import webql/lang/resolver/reference
import webql/lang/source

/// The top (or root) level operation.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
pub type Module {
  Module(operation: Operation, span: source.Span)
}

/// A operation with inputs, outputs, and definitions that wire data flow.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
///     -> out: Int { ... }
pub type Operation {
  Operation(
    reference: reference.Operation,
    inputs: List(Parameter),
    outputs: List(Parameter),
    definitions: List(Definition),
    span: source.Span,
  )
}

/// A named input or output with a typename.
///
/// ## Examples
///
///     in: Int
///     out: String
pub type Parameter {
  Parameter(
    name: String,
    typename: Typename,
    reference: reference.Access,
    span: source.Span,
  )
}

/// A typename describing the shape of a field.
///
/// ## Examples
///
///     String
///     Int
pub type Typename {
  Typename(name: String, reference: reference.Typename, span: source.Span)
}

/// An statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     Inner = in: Int -> out: Int { ... }
///     1 -> m.l
///     m.out -> .out
pub type Definition {
  Binding(
    name: String,
    reference: reference.Binding,
    value: Reference,
    span: source.Span,
  )
  Edge(from: Reference, to: Reference, span: source.Span)
}

/// A reference used in an definition.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
///     Math
///     in: Int -> out: Int { ... }
pub type Reference {
  Access(path: List(String), reference: reference.Access, span: source.Span)
  Node(name: String, reference: reference.Node, span: source.Span)
  Literal(value: Primitive, reference: reference.Typename, span: source.Span)
  SubOperation(
    name: String,
    reference: reference.Operation,
    operation: Operation,
    span: source.Span,
  )
}

/// A literal embedded directly in the graph.
///
/// ## Examples
///
///     3
///     3.3
///     "hello world"
pub type Primitive {
  Int(value: Int, span: source.Span)
  Float(value: Float, span: source.Span)
  String(value: String, span: source.Span)
}
