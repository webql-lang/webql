import webql/compiler/context
import webql/compiler/environment as schema
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/source

pub fn resolve_module_through_public_entrypoint_test() {
  let schema = schema.add_typename(schema.new(), "Int")
  let context = context.new()

  let module_to_resolve =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              span: source.Span(start: 8, end: 11),
            ),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PrimitiveOutput(
              value: ast.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              span: source.Span(start: 15, end: 16),
            ),
            to: ast.PortInput(
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

  let assert Ok(#(module, _context)) =
    module_to_resolve
    |> resolver.new()
    |> resolver.resolve(schema, context)

  assert module
    == hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [
          hir.Return(
            name: "out",
            typename: hir.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 8, end: 11),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          hir.Edge(
            from: hir.PrimitiveOutput(
              value: hir.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              typename: reference.Typename(0),
              span: source.Span(start: 15, end: 16),
            ),
            to: hir.PortInput(
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
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 26),
    )
}

pub fn resolve_returns_duplicate_edge_from_public_entrypoint_test() {
  let schema = schema.add_typename(schema.new(), "Int")
  let context = context.new()

  let module_to_resolve =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              span: source.Span(start: 8, end: 11),
            ),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [
          ast.Edge(
            from: ast.PrimitiveOutput(
              value: ast.Int(
                name: "Int",
                value: 1,
                span: source.Span(start: 15, end: 16),
              ),
              span: source.Span(start: 15, end: 16),
            ),
            to: ast.PortInput(
              path: ["out"],
              span: source.Span(start: 20, end: 24),
            ),
            span: source.Span(start: 15, end: 24),
          ),
          ast.Edge(
            from: ast.PrimitiveOutput(
              value: ast.Int(
                name: "Int",
                value: 2,
                span: source.Span(start: 25, end: 26),
              ),
              span: source.Span(start: 25, end: 26),
            ),
            to: ast.PortInput(
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
    module_to_resolve
    |> resolver.new()
    |> resolver.resolve(schema, context)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(["out"]),
      span: source.Span(start: 25, end: 34),
    )
}
