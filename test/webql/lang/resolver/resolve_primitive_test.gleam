import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_primitive
import webql/lang/source

pub fn resolve_int_value_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let value_to_resolve =
    parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3))

  let assert Ok(resolved) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert resolved
    == ast.Literal(
      value: ast.Int(value: 123, span: source.Span(start: 0, end: 3)),
      reference: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_float_value_test() {
  let registry = registry.new(typenames: ["Float"], nodes: [])

  let value_to_resolve =
    parser_ast.Float(value: 1.23, span: source.Span(start: 0, end: 4))

  let assert Ok(resolved) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert resolved
    == ast.Literal(
      value: ast.Float(value: 1.23, span: source.Span(start: 0, end: 4)),
      reference: reference.Typename(0),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_value_test() {
  let registry = registry.new(typenames: ["String"], nodes: [])

  let value_to_resolve =
    parser_ast.String(value: "hello", span: source.Span(start: 0, end: 7))

  let assert Ok(resolved) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert resolved
    == ast.Literal(
      value: ast.String(value: "hello", span: source.Span(start: 0, end: 7)),
      reference: reference.Typename(0),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_int_value_returns_unknown_type_when_int_is_not_registered_test() {
  let registry = registry.new(typenames: [], nodes: [])

  let value_to_resolve =
    parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3))

  let assert Error(error) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_float_value_returns_unknown_type_when_float_is_not_registered_test() {
  let registry = registry.new(typenames: [], nodes: [])

  let value_to_resolve =
    parser_ast.Float(value: 1.23, span: source.Span(start: 0, end: 4))

  let assert Error(error) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Float"),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_value_returns_unknown_type_when_string_is_not_registered_test() {
  let registry = registry.new(typenames: [], nodes: [])

  let value_to_resolve =
    parser_ast.String(value: "hello", span: source.Span(start: 0, end: 7))

  let assert Error(error) =
    resolve_primitive.resolve(registry, value_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("String"),
      span: source.Span(start: 0, end: 7),
    )
}
