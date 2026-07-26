import webql/compiler/lowerer/lower_graph
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_graph_test() {
  let graph =
    hir.Graph(
      parameters: [
        hir.Parameter(
          name: "in",
          port: hir.Port(
            name: "Int",
            reference: reference.Port(0),
            span: source.Span(start: 4, end: 7),
          ),
          reference: reference.Parameter(0),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        hir.Return(
          name: "out",
          port: hir.Port(
            name: "Int",
            reference: reference.Port(0),
            span: source.Span(start: 15, end: 18),
          ),
          reference: reference.Return(0),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      nodes: [
        hir.Node(
          name: "m",
          node: "Math",
          kind: reference.Kind(0),
          reference: reference.Node(0),
          span: source.Span(start: 19, end: 27),
        ),
      ],
      edges: [
        hir.Edge(
          source: hir.Output(
            path: ["m", "value"],
            reference: reference.Output(0),
            span: source.Span(start: 28, end: 35),
          ),
          target: hir.Input(
            path: ["out"],
            reference: reference.Input(0),
            span: source.Span(start: 39, end: 43),
          ),
          reference: reference.Edge(0),
          span: source.Span(start: 28, end: 43),
        ),
      ],
      span: source.Span(start: 0, end: 45),
    )

  assert lower_graph.lower(graph)
    == graph.Graph(
      parameters: [graph.Parameter(name: "in", port: "Int")],
      returns: [graph.Return(name: "out", port: "Int")],
      nodes: [graph.Node(name: "m", node: "Math")],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["m", "value"]),
          target: graph.Input(path: ["out"]),
        ),
      ],
    )
}
