import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/primative
import webql/lang/source

pub fn get_int_typename_test() {
  let primitive = parser_ast.Int(value: 123, span: source.Span(start: 0, end: 3))

  assert primative.get_typename(primitive) == "Int"
}

pub fn get_float_typename_test() {
  let primitive =
    parser_ast.Float(value: 1.23, span: source.Span(start: 0, end: 4))

  assert primative.get_typename(primitive) == "Float"
}

pub fn get_string_typename_test() {
  let primitive =
    parser_ast.String(value: "hello", span: source.Span(start: 0, end: 7))

  assert primative.get_typename(primitive) == "String"
}
