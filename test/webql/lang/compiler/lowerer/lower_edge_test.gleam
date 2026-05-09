import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_edge
import webql/lang/compiler/reference
import webql/lang/compiler/source

pub fn lower_port_edge_test() {
  let edge =
    hir.Edge(
      from: hir.PortOutput(
        path: ["m", "value"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 7),
      ),
      to: hir.PortInput(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 11, end: 15),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 15),
    )

  assert lower_edge.lower(edge)
    == graph.Edge(
      from: graph.Output(path: ["m", "value"]),
      to: graph.Input(path: ["out"]),
    )
}

pub fn lower_primitive_edge_output_test() {
  let edge =
    hir.Edge(
      from: hir.PrimitiveOutput(
        value: hir.Int(
          name: "Int",
          value: 1,
          span: source.Span(start: 0, end: 1),
        ),
        typename: reference.Typename(0),
        span: source.Span(start: 0, end: 1),
      ),
      to: hir.PortInput(
        path: ["m", "left"],
        reference: reference.Input(0),
        span: source.Span(start: 5, end: 11),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 11),
    )

  assert lower_edge.lower(edge)
    == graph.Edge(
      from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
      to: graph.Input(path: ["m", "left"]),
    )
}
