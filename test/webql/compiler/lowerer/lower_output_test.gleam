import webql/compiler/lowerer/lower_output
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_output_lowers_port_output_test() {
  let output =
    hir.PortOutput(
      path: ["result"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 6),
    )

  assert lower_output.lower(output) == graph.Output(path: ["result"])
}

pub fn lower_output_lowers_multi_part_port_output_test() {
  let output =
    hir.PortOutput(
      path: ["node", "value"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 10),
    )

  assert lower_output.lower(output) == graph.Output(path: ["node", "value"])
}

pub fn lower_output_lowers_int_primitive_test() {
  let output =
    hir.PrimitiveOutput(
      value: hir.Int(
        name: "Int",
        value: 42,
        span: source.Span(start: 0, end: 2),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 2),
    )

  assert lower_output.lower(output)
    == graph.PrimitiveOutput(value: graph.IntPrimitive(42))
}

pub fn lower_output_lowers_float_primitive_test() {
  let output =
    hir.PrimitiveOutput(
      value: hir.Float(
        name: "Float",
        value: 3.14,
        span: source.Span(start: 0, end: 4),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 4),
    )

  assert lower_output.lower(output)
    == graph.PrimitiveOutput(value: graph.FloatPrimitive(3.14))
}

pub fn lower_output_lowers_string_primitive_test() {
  let output =
    hir.PrimitiveOutput(
      value: hir.String(
        name: "String",
        value: "hello",
        span: source.Span(start: 0, end: 7),
      ),
      typename: reference.Typename(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_output.lower(output)
    == graph.PrimitiveOutput(value: graph.StringPrimitive("hello"))
}
