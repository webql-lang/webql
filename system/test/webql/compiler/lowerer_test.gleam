import webql/compiler/lowerer
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lowerer_lowers_document_test() {
  let document =
    hir.Document(
      graph: hir.Graph(
        parameters: [],
        returns: [
          hir.Return(
            name: "out",
            port: hir.Port(
              name: "Int",
              reference: reference.Port(0),
              span: source.Span(start: 8, end: 11),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        nodes: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 14),
    )

  let lowerer = lowerer.new(document)

  assert lowerer.lower(lowerer)
    == graph.Graph(
      parameters: [],
      returns: [graph.Return(name: "out", port: "Int")],
      nodes: [],
      edges: [],
    )
}
