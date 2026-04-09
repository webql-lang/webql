import webql/lang/resolver/reference
import webql/lang/source

/// Resolved operation with all names and types bound.
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

/// Resolved input or output field.
pub type Field {
  Field(
    name: String,
    port: reference.Port,
    annotation: Annotation,
    span: source.Span,
  )
}

/// Resolved type annotation.
pub type Annotation {
  NamedTypeAnnotation(typename: reference.Type, name: String, span: source.Span)
  ListTypeAnnotation(
    typename: reference.Type,
    of: Annotation,
    span: source.Span,
  )
}

/// Resolved executable statement.
pub type Expression {
  BindingExpression(
    alias: String,
    node: reference.Node,
    name: String,
    span: source.Span,
  )
  EdgeExpression(from: Reference, to: Reference, span: source.Span)
}

/// Fully resolved reference.
pub type Reference {
  OperationPortReference(name: String, port: reference.Port, span: source.Span)
  NodePortReference(
    name: String,
    alias: String,
    port: reference.Port,
    span: source.Span,
  )
  ValueReference(value: Value, typename: reference.Type, span: source.Span)
}

/// Literal value with known type.
pub type Value {
  IntValue(value: Int, span: source.Span)
  FloatValue(value: Float, span: source.Span)
  StringValue(value: String, span: source.Span)
}
