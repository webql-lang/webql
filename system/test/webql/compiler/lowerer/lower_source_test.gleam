import webql/compiler/lowerer/lower_source
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_source_lowers_port_output_test() {
  let output =
    hir.Output(
      path: ["result"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 6),
    )

  assert lower_source.lower(output) == graph.Output(path: ["result"])
}

pub fn lower_source_lowers_multi_part_port_output_test() {
  let output =
    hir.Output(
      path: ["node", "value"],
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 10),
    )

  assert lower_source.lower(output) == graph.Output(path: ["node", "value"])
}

pub fn lower_source_lowers_int_value_test() {
  let output =
    hir.Static(
      value: hir.Int(
        name: "Int",
        value: 42,
        span: source.Span(start: 0, end: 2),
      ),
      port: reference.Port(0),
      span: source.Span(start: 0, end: 2),
    )

  assert lower_source.lower(output) == graph.Static(value: graph.Int(42))
}

pub fn lower_source_lowers_float_value_test() {
  let output =
    hir.Static(
      value: hir.Float(
        name: "Float",
        value: 3.14,
        span: source.Span(start: 0, end: 4),
      ),
      port: reference.Port(0),
      span: source.Span(start: 0, end: 4),
    )

  assert lower_source.lower(output) == graph.Static(value: graph.Float(3.14))
}

pub fn lower_source_lowers_string_value_test() {
  let output =
    hir.Static(
      value: hir.String(
        name: "String",
        value: "hello",
        span: source.Span(start: 0, end: 7),
      ),
      port: reference.Port(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_source.lower(output)
    == graph.Static(value: graph.String("hello"))
}
