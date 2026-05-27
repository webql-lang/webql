import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_edge
import webql/compiler/source

pub fn resolve_port_edge_test() {
  let context =
    context.new()
    |> context.add_output(["math", "out"], reference.Port(0))
    |> context.add_input(["out"], reference.Port(0))

  let edge_to_resolve =
    ast.Edge(
      source: ast.Output(
        path: ["math", "out"],
        span: source.Span(start: 0, end: 8),
      ),
      target: ast.Input(path: ["out"], span: source.Span(start: 12, end: 16)),
      span: source.Span(start: 0, end: 16),
    )

  let assert Ok(edge) =
    resolve_edge.resolve(
      environment.new(),
      context,
      edge_to_resolve,
      reference.Edge(0),
    )

  assert edge
    == hir.Edge(
      source: hir.Output(
        path: ["math", "out"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 8),
      ),
      target: hir.Input(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 12, end: 16),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 16),
    )
}

pub fn resolve_value_output_edge_test() {
  let schema = environment.add_port(environment.new(), "String")
  let context = context.add_input(context.new(), ["out"], reference.Port(0))

  let edge_to_resolve =
    ast.Edge(
      source: ast.Literal(
        value: ast.String(
          name: "String",
          value: "test",
          span: source.Span(start: 0, end: 6),
        ),
        span: source.Span(start: 0, end: 6),
      ),
      target: ast.Input(path: ["out"], span: source.Span(start: 10, end: 14)),
      span: source.Span(start: 0, end: 14),
    )

  let assert Ok(edge) =
    resolve_edge.resolve(schema, context, edge_to_resolve, reference.Edge(0))

  assert edge
    == hir.Edge(
      source: hir.Literal(
        value: hir.String(
          name: "String",
          value: "test",
          span: source.Span(start: 0, end: 6),
        ),
        port: reference.Port(0),
        span: source.Span(start: 0, end: 6),
      ),
      target: hir.Input(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 10, end: 14),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 14),
    )
}

pub fn resolve_returns_unknown_output_for_missing_port_output_test() {
  let context = context.add_input(context.new(), ["out"], reference.Port(0))

  let edge_to_resolve =
    ast.Edge(
      source: ast.Output(
        path: ["math", "out"],
        span: source.Span(start: 0, end: 8),
      ),
      target: ast.Input(path: ["out"], span: source.Span(start: 12, end: 16)),
      span: source.Span(start: 0, end: 16),
    )

  let assert Error(error) =
    resolve_edge.resolve(
      environment.new(),
      context,
      edge_to_resolve,
      reference.Edge(0),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownOutput(["math", "out"]),
      span: source.Span(start: 0, end: 8),
    )
}

pub fn resolve_returns_unknown_input_for_missing_port_input_test() {
  let context =
    context.add_output(context.new(), ["math", "out"], reference.Port(0))

  let edge_to_resolve =
    ast.Edge(
      source: ast.Output(
        path: ["math", "out"],
        span: source.Span(start: 0, end: 8),
      ),
      target: ast.Input(path: ["out"], span: source.Span(start: 12, end: 16)),
      span: source.Span(start: 0, end: 16),
    )

  let assert Error(error) =
    resolve_edge.resolve(
      environment.new(),
      context,
      edge_to_resolve,
      reference.Edge(0),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownInput(["out"]),
      span: source.Span(start: 12, end: 16),
    )
}

pub fn resolve_returns_duplicate_input_edge_for_existing_edge_test() {
  let context =
    context.new()
    |> context.add_output(["math", "out"], reference.Port(0))
    |> context.add_input(["out"], reference.Port(0))
    |> context.add_edge(reference.Input(0))

  let edge_to_resolve =
    ast.Edge(
      source: ast.Output(
        path: ["math", "out"],
        span: source.Span(start: 0, end: 8),
      ),
      target: ast.Input(path: ["out"], span: source.Span(start: 12, end: 16)),
      span: source.Span(start: 0, end: 16),
    )

  let assert Error(error) =
    resolve_edge.resolve(
      environment.new(),
      context,
      edge_to_resolve,
      reference.Edge(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(["out"]),
      span: source.Span(start: 0, end: 16),
    )
}
