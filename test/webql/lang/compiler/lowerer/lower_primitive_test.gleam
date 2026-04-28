import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_primitive
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_int_primitive_test() {
  assert lower_primitive.lower(ast.Int(
      name: "Int",
      value: 1,
      span: source.Span(start: 0, end: 1),
    ))
    == ir.IntPrimitive(1)
}

pub fn lower_float_primitive_test() {
  assert lower_primitive.lower(ast.Float(
      name: "Float",
      value: 1.23,
      span: source.Span(start: 0, end: 4),
    ))
    == ir.FloatPrimitive(1.23)
}

pub fn lower_string_primitive_test() {
  assert lower_primitive.lower(ast.String(
      name: "String",
      value: "ok",
      span: source.Span(start: 0, end: 4),
    ))
    == ir.StringPrimitive("ok")
}
