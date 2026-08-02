import webql/compiler/lowerer/lower_document
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/graph

pub fn lower_document_test() {
  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
        span: source.Span(start: 0, end: 2),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 2),
    )

  assert lower_document.lower(document)
    == graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
}
