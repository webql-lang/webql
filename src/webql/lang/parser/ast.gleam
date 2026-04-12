import webql/lang/source

/// Top-level module.
///
/// Represents an executable graph with inputs, outputs,
/// nested operations, and expressions that wire data flow.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
///     -> out: Int { ... }
pub type Module {
  Module(
    inputs: List(Parameter),
    outputs: List(Parameter),
    expressions: List(Expression),
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
  Parameter(name: String, typename: Typename, span: source.Span)
}

/// A typename describing the shape of a field.
///
/// ## Examples
///
///     String
///     Int
///     [Bool]
pub type Typename {
  Typename(name: String, span: source.Span)
}

/// An executable statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     Inner = in: Int -> out: Int { ... }
///     1 -> m.l
///     m.out -> .out
pub type Expression {
  Binding(name: String, value: Reference, span: source.Span)
  Edge(from: Reference, to: Reference, span: source.Span)
}

/// A reference used in an expression.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
///     Node
///     in: Int -> out: Int { ... }
pub type Reference {
  Access(path: List(String), span: source.Span)
  Node(name: String, span: source.Span)
  Literal(value: Primitive, span: source.Span)
  Operation(
    inputs: List(Parameter),
    outputs: List(Parameter),
    expressions: List(Expression),
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
