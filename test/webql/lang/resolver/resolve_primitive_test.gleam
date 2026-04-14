import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/resolve_primitive
import webql/lang/source

pub fn resolve_int_primitive_test() {
  let value_to_resolve =
    parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.Int(value: 123, span: source.Span(start: 0, end: 3))
}

pub fn resolve_float_primitive_test() {
  let value_to_resolve =
    parser_ast.Float(value: 1.23, span: source.Span(start: 0, end: 4))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.Float(value: 1.23, span: source.Span(start: 0, end: 4))
}

pub fn resolve_string_primitive_test() {
  let value_to_resolve =
    parser_ast.String(value: "hello", span: source.Span(start: 0, end: 7))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.String(value: "hello", span: source.Span(start: 0, end: 7))
}
