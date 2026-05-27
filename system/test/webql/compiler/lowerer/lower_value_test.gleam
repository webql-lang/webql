import webql/compiler/lowerer/lower_value
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_int_value_test() {
  assert lower_value.lower(hir.Int(
      name: "Int",
      value: 1,
      span: source.Span(start: 0, end: 1),
    ))
    == graph.Int(1)
}

pub fn lower_float_value_test() {
  assert lower_value.lower(hir.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    ))
    == graph.Float(1.23)
}

pub fn lower_string_value_test() {
  assert lower_value.lower(hir.String(
      name: "String",
      value: "ok",
      span: source.Span(start: 0, end: 4),
    ))
    == graph.String("ok")
}
