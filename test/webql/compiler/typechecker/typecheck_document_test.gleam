import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_document

pub fn typecheck_accepts_matching_edge_types_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))

  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [
          resolver.Edge(
            source: resolver.Literal(
              value: resolver.String(
                name: "String",
                value: "ok",
                span: source.Span(start: 0, end: 4),
              ),
              port: reference.Port(1),
              span: source.Span(start: 0, end: 4),
            ),
            target: resolver.Input(
              path: ["string"],
              reference: reference.Input(0),
              span: source.Span(start: 8, end: 15),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 0, end: 15),
          ),
        ],
        span: source.Span(start: 0, end: 15),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_document.typecheck(document, context) == Ok(document)
}

pub fn typecheck_rejects_mismatched_edge_types_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))

  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [
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
              path: ["string"],
              reference: reference.Input(0),
              span: source.Span(start: 5, end: 12),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 0, end: 12),
          ),
        ],
        span: source.Span(start: 0, end: 12),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 12),
    )

  let assert Error(error) = typecheck_document.typecheck(document, context)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Port(1),
        found: reference.Port(0),
      ),
      span: source.Span(start: 0, end: 12),
    )
}

pub fn typecheck_rejects_nested_supernode_mismatch_test() {
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Port(1))

  let context =
    context.add_context(context.new(), reference.Supernode(0), nested_context)

  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [],
        nodes: [
          resolver.Supernode(
            name: "Inner",
            graph: resolver.Graph(
              parameters: [],
              returns: [],
              nodes: [],
              edges: [
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
                    path: ["string"],
                    reference: reference.Input(0),
                    span: source.Span(start: 5, end: 12),
                  ),
                  reference: reference.Edge(0),
                  span: source.Span(start: 0, end: 12),
                ),
              ],
              span: source.Span(start: 0, end: 12),
            ),
            reference: reference.Supernode(0),
            span: source.Span(start: 0, end: 12),
          ),
        ],
        edges: [],
        span: source.Span(start: 0, end: 12),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 12),
    )

  let assert Error(error) = typecheck_document.typecheck(document, context)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Port(1),
        found: reference.Port(0),
      ),
      span: source.Span(start: 0, end: 12),
    )
}

pub fn typecheck_accepts_matching_nested_supernode_test() {
  let nested_context =
    context.add_input(context.new(), ["string"], reference.Port(1))

  let context =
    context.add_context(context.new(), reference.Supernode(0), nested_context)

  let document =
    resolver.Document(
      graph: resolver.Graph(
        parameters: [],
        returns: [],
        nodes: [
          resolver.Supernode(
            name: "Inner",
            graph: resolver.Graph(
              parameters: [],
              returns: [],
              nodes: [],
              edges: [
                resolver.Edge(
                  source: resolver.Literal(
                    value: resolver.String(
                      name: "String",
                      value: "ok",
                      span: source.Span(start: 0, end: 4),
                    ),
                    port: reference.Port(1),
                    span: source.Span(start: 0, end: 4),
                  ),
                  target: resolver.Input(
                    path: ["string"],
                    reference: reference.Input(0),
                    span: source.Span(start: 8, end: 15),
                  ),
                  reference: reference.Edge(0),
                  span: source.Span(start: 0, end: 15),
                ),
              ],
              span: source.Span(start: 0, end: 15),
            ),
            reference: reference.Supernode(0),
            span: source.Span(start: 0, end: 15),
          ),
        ],
        edges: [],
        span: source.Span(start: 0, end: 15),
      ),
      reference: reference.Document(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_document.typecheck(document, context) == Ok(document)
}
