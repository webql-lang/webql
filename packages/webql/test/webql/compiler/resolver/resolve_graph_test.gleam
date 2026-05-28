import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_graph
import webql/compiler/source

pub fn resolve_graph_resolves_body_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let graph_to_resolve =
    ast.Graph(
      parameters: [
        ast.Parameter(
          name: "in",
          port: ast.Port(name: "Int", span: source.Span(start: 4, end: 7)),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        ast.Return(
          name: "out",
          port: ast.Port(name: "Int", span: source.Span(start: 15, end: 18)),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      nodes: [
        ast.Supernode(
          name: "Inner",
          graph: ast.Graph(
            parameters: [],
            returns: [
              ast.Return(
                name: "value",
                port: ast.Port(
                  name: "Int",
                  span: source.Span(start: 35, end: 38),
                ),
                span: source.Span(start: 28, end: 38),
              ),
            ],
            nodes: [],
            edges: [],
            span: source.Span(start: 20, end: 41),
          ),
          span: source.Span(start: 20, end: 41),
        ),
        ast.Node(
          name: "inner",
          node: "Inner",
          span: source.Span(start: 42, end: 55),
        ),
      ],
      edges: [
        ast.Edge(
          source: ast.Output(
            path: ["in"],
            span: source.Span(start: 54, end: 57),
          ),
          target: ast.Input(
            path: ["out"],
            span: source.Span(start: 61, end: 65),
          ),
          span: source.Span(start: 54, end: 65),
        ),
      ],
      span: source.Span(start: 0, end: 67),
    )

  let assert Ok(#(graph, _context)) =
    resolve_graph.resolve(schema, context.new(), graph_to_resolve)

  assert graph
    == hir.Graph(
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
        hir.Supernode(
          name: "Inner",
          graph: hir.Graph(
            parameters: [],
            returns: [
              hir.Return(
                name: "value",
                port: hir.Port(
                  name: "Int",
                  reference: reference.Port(0),
                  span: source.Span(start: 35, end: 38),
                ),
                reference: reference.Return(0),
                span: source.Span(start: 28, end: 38),
              ),
            ],
            nodes: [],
            edges: [],
            span: source.Span(start: 20, end: 41),
          ),
          reference: reference.Supernode(0),
          span: source.Span(start: 20, end: 41),
        ),
        hir.Node(
          name: "inner",
          node: "Inner",
          operation: reference.Operation(0),
          reference: reference.Node(0),
          span: source.Span(start: 42, end: 55),
        ),
      ],
      edges: [
        hir.Edge(
          source: hir.Output(
            path: ["in"],
            reference: reference.Output(0),
            span: source.Span(start: 54, end: 57),
          ),
          target: hir.Input(
            path: ["out"],
            reference: reference.Input(0),
            span: source.Span(start: 61, end: 65),
          ),
          reference: reference.Edge(0),
          span: source.Span(start: 54, end: 65),
        ),
      ],
      span: source.Span(start: 0, end: 67),
    )
}

pub fn resolve_graph_returns_duplicate_supernode_test() {
  let schema = environment.new()

  let graph_to_resolve =
    ast.Graph(
      parameters: [],
      returns: [],
      nodes: [
        ast.Supernode(
          name: "Inner",
          graph: ast.Graph(
            parameters: [],
            returns: [],
            nodes: [],
            edges: [],
            span: source.Span(start: 0, end: 0),
          ),
          span: source.Span(start: 0, end: 0),
        ),
        ast.Supernode(
          name: "Inner",
          graph: ast.Graph(
            parameters: [],
            returns: [],
            nodes: [],
            edges: [],
            span: source.Span(start: 1, end: 1),
          ),
          span: source.Span(start: 1, end: 1),
        ),
      ],
      edges: [],
      span: source.Span(start: 0, end: 1),
    )

  let assert Error(error) =
    resolve_graph.resolve(schema, context.new(), graph_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateSupernode("Inner"),
      span: source.Span(start: 1, end: 1),
    )
}

pub fn resolve_graph_returns_duplicate_edge_for_second_value_output_to_same_input_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let graph_to_resolve =
    ast.Graph(
      parameters: [],
      returns: [
        ast.Return(
          name: "out",
          port: ast.Port(name: "Int", span: source.Span(start: 7, end: 10)),
          span: source.Span(start: 2, end: 10),
        ),
      ],
      nodes: [],
      edges: [
        ast.Edge(
          source: ast.Literal(
            value: ast.Int(
              name: "Int",
              value: 1,
              span: source.Span(start: 13, end: 14),
            ),
            span: source.Span(start: 13, end: 14),
          ),
          target: ast.Input(
            path: ["out"],
            span: source.Span(start: 18, end: 22),
          ),
          span: source.Span(start: 13, end: 22),
        ),
        ast.Edge(
          source: ast.Literal(
            value: ast.Int(
              name: "Int",
              value: 2,
              span: source.Span(start: 23, end: 24),
            ),
            span: source.Span(start: 23, end: 24),
          ),
          target: ast.Input(
            path: ["out"],
            span: source.Span(start: 28, end: 32),
          ),
          span: source.Span(start: 23, end: 32),
        ),
      ],
      span: source.Span(start: 0, end: 34),
    )

  let assert Error(error) =
    resolve_graph.resolve(schema, context.new(), graph_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(["out"]),
      span: source.Span(start: 23, end: 32),
    )
}
