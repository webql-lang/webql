import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

pub fn typecheck_accepts_matching_value_edge_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))

  let edge =
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
    )

  assert typecheck_edge.typecheck(edge, context) == Ok(Nil)
}

pub fn typecheck_rejects_mismatched_value_edge_test() {
  let context = context.add_input(context.new(), ["string"], reference.Port(1))

  let edge =
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
    )

  assert typecheck_edge.typecheck(edge, context)
    == Error(diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Port(1),
        found: reference.Port(0),
      ),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_accepts_matching_port_edge_test() {
  let context =
    context.new()
    |> context.add_output(["math", "out"], reference.Port(0))
    |> context.add_input(["out"], reference.Port(0))

  let edge =
    resolver.Edge(
      source: resolver.Output(
        path: ["math", "out"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 8),
      ),
      target: resolver.Input(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 12, end: 16),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 16),
    )

  assert typecheck_edge.typecheck(edge, context) == Ok(Nil)
}
