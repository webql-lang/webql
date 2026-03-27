/// Top-level anonymous operation.
///
/// Represents an executable graph with inputs, outputs,
/// nested declarations, and expressions that wire data flow.
///
/// ## Examples
///
///     .in -> .out { ... }
///     -> .out { ... }
pub type Operation {
  Operation(
    inputs: List(Field),
    outputs: List(Field),
    declarations: List(Declaration),
    expressions: List(Expression),
  )
}

/// A reusable named operation declared within an operation.
///
/// Declarations may contain other declarations and expressions,
/// but are distinct from the anonymous top-level `Operation`.
///
/// ## Examples
///
///     in: Int -> out: Int {
///       Inner = .in: Int -> .out: Int { ... }
///     }
pub type Declaration {
  Declaration(
    name: String,
    inputs: List(Field),
    outputs: List(Field),
    declarations: List(Declaration),
    expressions: List(Expression),
  )
}

/// A named input or output with a type annotation.
///
/// ## Examples
///
///     in: Int
///     out: String
pub type Field {
  Field(name: String, annotation: Annotation)
}

/// A type annotation describing the shape of a field.
///
/// ## Examples
///
///     String
///     Int
///     [Bool]
pub type Annotation {
  NamedTypeAnnotation(name: String)
  ListTypeAnnotation(of: Annotation)
}

/// An executable statement inside an operation or declaration body.
///
/// ## Examples
///
///     m = Math
///     1 -> m.l
///     m.out -> .out
pub type Expression {
  BindingExpression(alias: String, node: String)
  EdgeExpression(from: Reference, to: Reference)
}

/// A reference used in an expression.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
pub type Reference {
  OperationPortReference(port: String)
  NodePortReference(alias: String, port: String)
  ValueReference(value: Value)
}

/// A literal value embedded directly in the graph.
///
/// ## Examples
///
///     3
///     3.3
///     "hello world"
pub type Value {
  IntValue(value: Int)
  FloatValue(value: Float)
  StringValue(value: String)
}
