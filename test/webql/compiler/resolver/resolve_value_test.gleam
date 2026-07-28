import webql/compiler/parser
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_value
import webql/compiler/source

pub fn resolve_int_value_test() {
  let value_to_resolve =
    parser.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))

  let resolved = resolve_value.resolve(value_to_resolve)

  assert resolved
    == hir.Int(name: "Int", value: 123, span: source.Span(start: 0, end: 3))
}

pub fn resolve_float_value_test() {
  let value_to_resolve =
    parser.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    )

  let resolved = resolve_value.resolve(value_to_resolve)

  assert resolved
    == hir.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    )
}

pub fn resolve_string_value_test() {
  let value_to_resolve =
    parser.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )

  let resolved = resolve_value.resolve(value_to_resolve)

  assert resolved
    == hir.String(
      name: "String",
      value: "hello",
      span: source.Span(start: 0, end: 7),
    )
}
