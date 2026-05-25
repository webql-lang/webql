import webql/compiler/lowerer/lower_primitive
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_int_primitive_test() {
  assert lower_primitive.lower(hir.Int(
      name: "Int",
      value: 1,
      span: source.Span(start: 0, end: 1),
    ))
    == graph.IntPrimitive(1)
}

pub fn lower_float_primitive_test() {
  assert lower_primitive.lower(hir.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    ))
    == graph.FloatPrimitive(1.23)
}

pub fn lower_string_primitive_test() {
  assert lower_primitive.lower(hir.String(
      name: "String",
      value: "ok",
      span: source.Span(start: 0, end: 4),
    ))
    == graph.StringPrimitive("ok")
}
