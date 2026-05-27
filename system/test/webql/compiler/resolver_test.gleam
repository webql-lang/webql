import webql/compiler/context
import webql/compiler/environment as schema
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/source

pub fn resolve_document_through_public_entrypoint_test() {
  let schema = schema.add_port(schema.new(), "Int")
  let context = context.new()

  let document_to_resolve =
    ast.Document(
      graph: ast.Graph(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            port: ast.Port(name: "Int", span: source.Span(start: 8, end: 11)),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        nodes: [],
        edges: [
          ast.Edge(
            source: ast.Static(
              value: ast.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              span: source.Span(start: 15, end: 16),
            ),
            target: ast.Input(
              path: ["out"],
              span: source.Span(start: 20, end: 24),
            ),
            span: source.Span(start: 15, end: 24),
          ),
        ],
        span: source.Span(start: 0, end: 26),
      ),
      span: source.Span(start: 0, end: 26),
    )

  let assert Ok(#(document, _context)) =
    document_to_resolve
    |> resolver.new()
    |> resolver.resolve(schema, context)

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
        edges: [
          hir.Edge(
            source: hir.Static(
              value: hir.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              port: reference.Port(0),
              span: source.Span(start: 15, end: 16),
            ),
            target: hir.Input(
              path: ["out"],
              reference: reference.Input(0),
              span: source.Span(start: 20, end: 24),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 15, end: 24),
          ),
        ],
        span: source.Span(start: 0, end: 26),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 26),
    )
}

pub fn resolve_returns_duplicate_edge_from_public_entrypoint_test() {
  let schema = schema.add_port(schema.new(), "Int")
  let context = context.new()

  let document_to_resolve =
    ast.Document(
      graph: ast.Graph(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            port: ast.Port(name: "Int", span: source.Span(start: 8, end: 11)),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        nodes: [],
        edges: [
          ast.Edge(
            source: ast.Static(
              value: ast.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              span: source.Span(start: 15, end: 16),
            ),
            target: ast.Input(
              path: ["out"],
              span: source.Span(start: 20, end: 24),
            ),
            span: source.Span(start: 15, end: 24),
          ),
          ast.Edge(
            source: ast.Static(
              value: ast.Int(
                name: "Int",
                value: 2,
                span: source.Span(start: 25, end: 26),
              ),
              span: source.Span(start: 25, end: 26),
            ),
            target: ast.Input(
              path: ["out"],
              span: source.Span(start: 30, end: 34),
            ),
            span: source.Span(start: 25, end: 34),
          ),
        ],
        span: source.Span(start: 0, end: 36),
      ),
      span: source.Span(start: 0, end: 36),
    )

  let assert Error(error) =
    document_to_resolve
    |> resolver.new()
    |> resolver.resolve(schema, context)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(["out"]),
      span: source.Span(start: 25, end: 34),
    )
}
