import webql/compiler/lowerer
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/graph

pub fn lowerer_lowers_document_test() {
  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [
          resolver.Return(
            name: "out",
            port: resolver.Port(
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
