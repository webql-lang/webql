import webql/lang/lexer/token
import webql/lang/source/position

/// Represents a AST relative to a span and the next available tokens.
pub type Parsed(a) {
  Parsed(node: a, span: position.Span, tokens: List(token.Token))
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
    span: position.Span,
  )
  NestedOperation(
    name: String,
    inputs: List(Field),
    outputs: List(Field),
    operations: List(Operation),
    expressions: List(Expression),
    span: position.Span,
  )
}

/// A named input or output with a type annotation.
///
/// ## Examples
///
///     in: Int
///     out: String
pub type Field {
  Field(name: String, annotation: Annotation, span: position.Span)
}

/// A type annotation describing the shape of a field.
///
/// ## Examples
///
///     String
///     Int
///     [Bool]
pub type Annotation {
  NamedTypeAnnotation(name: String, span: position.Span)
  ListTypeAnnotation(of: Annotation, span: position.Span)
}

/// An executable statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     1 -> m.l
///     m.out -> .out
pub type Expression {
  BindingExpression(alias: String, node: String, span: position.Span)
  EdgeExpression(from: Reference, to: Reference, span: position.Span)
}

/// A reference used in an expression.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
pub type Reference {
  OperationPortReference(port: String, span: position.Span)
  NodePortReference(alias: String, port: String, span: position.Span)
  ValueReference(value: Value, span: position.Span)
}

/// A literal value embedded directly in the graph.
///
/// ## Examples
///
///     3
///     3.3
///     "hello world"
pub type Value {
  IntValue(value: Int, span: position.Span)
  FloatValue(value: Float, span: position.Span)
  StringValue(value: String, span: position.Span)
}
