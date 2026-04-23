import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/resolve_primitive
import webql/compiler/source

pub fn resolve_int_primitive_test() {
  let value_to_resolve =
    parser_ast.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))
}

pub fn resolve_float_primitive_test() {
  let value_to_resolve =
    parser_ast.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    )

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_primitive_test() {
  let value_to_resolve =
    parser_ast.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == ast.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )
}
