import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_value
import webql/lang/source

pub fn resolve_int_value_test() {
  let registry = registry.new(typenames: ["Int"])

  let value_to_resolve =
    parser_ast.IntValue(value: 123, span: source.Span(start: 0, end: 3))

  let assert Ok(resolved) = resolve_value.resolve(registry, value_to_resolve)

  assert resolved
    == ast.ValueReference(
      value: ast.IntValue(value: 123, span: source.Span(start: 0, end: 3)),
      typename: reference.Type(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_float_value_test() {
  let registry = registry.new(typenames: ["Float"])

  let value_to_resolve =
    parser_ast.FloatValue(value: 1.23, span: source.Span(start: 0, end: 4))

  let assert Ok(resolved) = resolve_value.resolve(registry, value_to_resolve)

  assert resolved
    == ast.ValueReference(
      value: ast.FloatValue(value: 1.23, span: source.Span(start: 0, end: 4)),
      typename: reference.Type(0),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_value_test() {
  let registry = registry.new(typenames: ["String"])

  let value_to_resolve =
    parser_ast.StringValue(value: "hello", span: source.Span(start: 0, end: 7))

  let assert Ok(resolved) = resolve_value.resolve(registry, value_to_resolve)

  assert resolved
    == ast.ValueReference(
      value: ast.StringValue(
        value: "hello",
        span: source.Span(start: 0, end: 7),
      ),
      typename: reference.Type(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_int_value_returns_unknown_type_when_int_is_not_registered_test() {
  let registry = registry.new(typenames: [])

  let value_to_resolve =
    parser_ast.IntValue(value: 123, span: source.Span(start: 0, end: 3))

  let assert Error(error) = resolve_value.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Int"),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_float_value_returns_unknown_type_when_float_is_not_registered_test() {
  let registry = registry.new(typenames: [])

  let value_to_resolve =
    parser_ast.FloatValue(value: 1.23, span: source.Span(start: 0, end: 4))

  let assert Error(error) = resolve_value.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Float"),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_value_returns_unknown_type_when_string_is_not_registered_test() {
  let registry = registry.new(typenames: [])

  let value_to_resolve =
    parser_ast.StringValue(value: "hello", span: source.Span(start: 0, end: 7))

  let assert Error(error) = resolve_value.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("String"),
      span: source.Span(start: 0, end: 7),
    )
}
