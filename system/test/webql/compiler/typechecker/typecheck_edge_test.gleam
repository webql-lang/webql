import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

pub fn typecheck_accepts_matching_primitive_edge_test() {
  let context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let edge =
    hir.Edge(
      from: hir.PrimitiveOutput(
        value: hir.String(
          name: "String",
          value: "ok",
          span: source.Span(start: 0, end: 4),
        ),
        typename: reference.Typename(1),
        span: source.Span(start: 0, end: 4),
      ),
      to: hir.PortInput(
        path: ["string"],
        reference: reference.Input(0),
        span: source.Span(start: 8, end: 15),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_edge.typecheck(edge, context) == Ok(Nil)
}

pub fn typecheck_rejects_mismatched_primitive_edge_test() {
  let context =
    context.add_input(context.new(), ["string"], reference.Typename(1))

  let edge =
    hir.Edge(
      from: hir.PrimitiveOutput(
        value: hir.Int(
          name: "Int",
          value: 1,
          span: source.Span(start: 0, end: 1),
        ),
        typename: reference.Typename(0),
        span: source.Span(start: 0, end: 1),
      ),
      to: hir.PortInput(
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
        expected: reference.Typename(1),
        found: reference.Typename(0),
      ),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_accepts_matching_port_edge_test() {
  let context =
    context.new()
    |> context.add_output(["math", "out"], reference.Typename(0))
    |> context.add_input(["out"], reference.Typename(0))

  let edge =
    hir.Edge(
      from: hir.PortOutput(
        path: ["math", "out"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 8),
      ),
      to: hir.PortInput(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 12, end: 16),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 16),
    )

  assert typecheck_edge.typecheck(edge, context) == Ok(Nil)
}
