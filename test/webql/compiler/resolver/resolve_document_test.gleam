import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_document
import webql/compiler/source

pub fn resolve_document_wraps_resolved_graph_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let document_to_resolve =
    parser.Document(
      graph: parser.Graph(
        parameters: [],
        returns: [
          parser.Return(
            name: "out",
            port: parser.Port(name: "Int", span: source.Span(start: 8, end: 11)),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        nodes: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      span: source.Span(start: 0, end: 14),
    )

  let assert Ok(#(document, _context)) =
    resolve_document.resolve(
      schema,
      context.new(),
      document_to_resolve,
      reference.Document(0),
    )

  assert document
    == hir.Document(
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
}
