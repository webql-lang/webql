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
    inputs: List(Input),
    outputs: List(Output),
    definitions: List(Definition),
    span: source.Span,
  )
}

/// A named input with a typename.
///
/// ## Examples
///
///     in: Int
pub type Input {
  Input(name: String, typename: Typename, span: source.Span)
}

/// A named output with a typename.
///
/// ## Examples
///
///     out: String
pub type Output {
  Output(name: String, typename: Typename, span: source.Span)
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

/// An statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     Inner = in: Int -> out: Int { ... }
///     1 -> m.l
///     m.out -> .out
pub type Definition {
  Binding(name: String, value: Reference, span: source.Span)
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
  InputAccess(path: List(String), span: source.Span)
  OutputAccess(path: List(String), span: source.Span)
  Node(name: String, span: source.Span)
  Literal(value: Primitive, span: source.Span)
  SubOperation(name: String, operation: Operation, span: source.Span)
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
