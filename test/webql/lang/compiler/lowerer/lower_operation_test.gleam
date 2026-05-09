import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_operation
import webql/lang/compiler/reference
import webql/lang/compiler/source

pub fn lower_operation_test() {
  let operation =
    hir.Operation(
      parameters: [
        hir.Parameter(
          name: "in",
          typename: hir.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 4, end: 7),
          ),
          reference: reference.Parameter(0),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        hir.Return(
          name: "out",
          typename: hir.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 15, end: 18),
          ),
          reference: reference.Return(0),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      definitions: [],
      bindings: [
        hir.Binding(
          name: "m",
          value: hir.NodeValue(
            name: "Math",
            reference: reference.Node(0),
            span: source.Span(start: 23, end: 27),
          ),
          reference: reference.Binding(0),
          span: source.Span(start: 19, end: 27),
        ),
      ],
      edges: [
        hir.Edge(
          from: hir.PortOutput(
            path: ["m", "value"],
            reference: reference.Output(0),
            span: source.Span(start: 28, end: 35),
          ),
          to: hir.PortInput(
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

  assert lower_operation.lower(operation)
    == graph.Operation(
      parameters: [graph.Parameter(name: "in", typename: "Int")],
      returns: [graph.Return(name: "out", typename: "Int")],
      nodes: [graph.ExternalNode(name: "m", node: "Math")],
      edges: [
        graph.Edge(
          from: graph.Output(path: ["m", "value"]),
          to: graph.Input(path: ["out"]),
        ),
      ],
    )
}
