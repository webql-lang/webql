import webql/lang/lexer/token
import webql/lang/source

/// Represents a AST relative to a span and the next available tokens.
pub type Parsed(a) {
  Parsed(node: a, span: source.Span, tokens: List(token.Token))
}

/// Top-level anonymous operation.
///
/// Represents an executable graph with inputs, outputs,
/// nested operations, and expressions that wire data flow.
///
/// ## Examples
///
///     .in -> .out { ... }
///     -> .out { ... }
///
///     in: Int -> out: Int {
///       Inner = .in: Int -> .out: Int { ... }
///     }
pub type Operation {
  Operation(
    inputs: List(Field),
    outputs: List(Field),
    operations: List(Operation),
    expressions: List(Expression),
    span: source.Span,
  )
  NestedOperation(
    name: String,
    inputs: List(Field),
    outputs: List(Field),
    operations: List(Operation),
    expressions: List(Expression),
    span: source.Span,
  )
}

/// A named input or output with a type annotation.
///
/// ## Examples
///
///     in: Int
///     out: String
pub type Field {
  Field(name: String, annotation: Annotation, span: source.Span)
}

/// A type annotation describing the shape of a field.
///
/// ## Examples
///
///     String
///     Int
///     [Bool]
pub type Annotation {
  NamedTypeAnnotation(name: String, span: source.Span)
}

/// An executable statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     1 -> m.l
///     m.out -> .out
pub type Expression {
  BindingExpression(alias: String, node: String, span: source.Span)
  EdgeExpression(from: Reference, to: Reference, span: source.Span)
}

/// A reference used in an expression.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
pub type Reference {
  OperationPortReference(port: String, span: source.Span)
  NodePortReference(alias: String, port: String, span: source.Span)
  ValueReference(value: Value, span: source.Span)
}

/// A literal value embedded directly in the graph.
///
/// ## Examples
///
///     3
///     3.3
///     "hello world"
pub type Value {
  IntValue(value: Int, span: source.Span)
  FloatValue(value: Float, span: source.Span)
  StringValue(value: String, span: source.Span)
}
