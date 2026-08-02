import webql/compiler/lowerer/lower_edge
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/graph

pub fn lower_port_edge_test() {
  let edge =
    resolver.Edge(
      source: resolver.Output(
        path: ["m", "value"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 7),
      ),
      target: resolver.Input(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 11, end: 15),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 15),
    )

  assert lower_edge.lower(edge)
    == graph.Edge(
      source: graph.Output(path: ["m", "value"]),
      target: graph.Input(path: ["out"]),
    )
}

pub fn lower_value_edge_output_test() {
  let edge =
    resolver.Edge(
      source: resolver.Literal(
        value: resolver.Int(
          name: "Int",
          value: 1,
          span: source.Span(start: 0, end: 1),
        ),
        port: reference.Port(0),
        span: source.Span(start: 0, end: 1),
      ),
      target: resolver.Input(
        path: ["m", "left"],
        reference: reference.Input(0),
        span: source.Span(start: 5, end: 11),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 11),
    )

  assert lower_edge.lower(edge)
    == graph.Edge(
      source: graph.Literal(value: graph.Int(1)),
      target: graph.Input(path: ["m", "left"]),
    )
}
