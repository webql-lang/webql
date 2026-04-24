import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_value
import webql/compiler/source
import webql/loader/schema

pub fn resolve_node_value_test() {
  let schema = schema.add_node(schema.new(), "Math")

  let value_to_resolve =
    parser_ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))

  let assert Ok(value) = resolve_value.resolve(schema, value_to_resolve)

  assert value
    == ast.NodeValue(
      name: "Math",
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_returns_unknown_node_for_missing_node_value_test() {
  let schema = schema.new()

  let value_to_resolve =
    parser_ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))

  let assert Error(error) = resolve_value.resolve(schema, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownNode("Math"),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_int_primitive_value_test() {
  let schema = schema.add_typename(schema.new(), "Int")

  let value_to_resolve =
    parser_ast.PrimitiveValue(
      value: parser_ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(value) = resolve_value.resolve(schema, value_to_resolve)

  assert value
    == ast.PrimitiveValue(
      value: ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_float_primitive_value_test() {
  let schema = schema.add_typename(schema.new(), "Float")

  let value_to_resolve =
    parser_ast.PrimitiveValue(
      value: parser_ast.Float(
        name: "Float",
        value: 1.23,
        span: source.Span(start: 0, end: 4),
      ),
      span: source.Span(start: 0, end: 4),
    )

  let assert Ok(value) = resolve_value.resolve(schema, value_to_resolve)

  assert value
    == ast.PrimitiveValue(
      value: ast.Float(
        name: "Float",
        value: 1.23,
        span: source.Span(start: 0, end: 4),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_primitive_value_test() {
  let schema = schema.add_typename(schema.new(), "String")

  let value_to_resolve =
    parser_ast.PrimitiveValue(
      value: parser_ast.String(
        name: "String",
        value: "hello",
        span: source.Span(start: 0, end: 7),
      ),
      span: source.Span(start: 0, end: 7),
    )

  let assert Ok(value) = resolve_value.resolve(schema, value_to_resolve)

  assert value
    == ast.PrimitiveValue(
      value: ast.String(
        name: "String",
        value: "hello",
        span: source.Span(start: 0, end: 7),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_returns_unknown_type_for_missing_primitive_typename_test() {
  let schema = schema.new()

  let value_to_resolve =
    parser_ast.PrimitiveValue(
      value: parser_ast.Int(
        name: "Int",
        value: 123,
        span: source.Span(start: 0, end: 3),
      ),
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) = resolve_value.resolve(schema, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
