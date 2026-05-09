import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/resolver/resolve_primitive
import webql/lang/compiler/source

pub fn resolve_int_primitive_test() {
  let value_to_resolve =
    ast.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == hir.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))
}

pub fn resolve_float_primitive_test() {
  let value_to_resolve =
    ast.Float(name: "Float", value: 1.23, span: source.Span(start: 0, end: 4))

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == hir.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_primitive_test() {
  let value_to_resolve =
    ast.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )

  let resolved = resolve_primitive.resolve(value_to_resolve)

  assert resolved
    == hir.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )
}
