import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/source
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

pub fn typecheck_accepts_matching_primitive_edge_test() {
  let runtime = runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let edge =
    ast.Edge(
      from: ast.PrimitiveOutput(
        value: ast.String(
          name: "String",
          value: "ok",
          span: source.Span(start: 0, end: 4),
        ),
        typename: reference.Typename(1),
        span: source.Span(start: 0, end: 4),
      ),
      to: ast.PortInput(
        path: ["string"],
        reference: reference.Input(0),
        span: source.Span(start: 8, end: 15),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 15),
    )

  assert typecheck_edge.typecheck(edge, runtime) == Ok(Nil)
}

pub fn typecheck_rejects_mismatched_primitive_edge_test() {
  let runtime = runtime.add_input(runtime.new(), ["string"], reference.Typename(1))

  let edge =
    ast.Edge(
      from: ast.PrimitiveOutput(
        value: ast.Int(
          name: "Int",
          value: 1,
          span: source.Span(start: 0, end: 1),
        ),
        typename: reference.Typename(0),
        span: source.Span(start: 0, end: 1),
      ),
      to: ast.PortInput(
        path: ["string"],
        reference: reference.Input(0),
        span: source.Span(start: 5, end: 12),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 12),
    )

  assert typecheck_edge.typecheck(edge, runtime)
    == Error(diagnostic.Diagnostic(
      kind: diagnostic.TypeMismatch(
        expected: reference.Typename(1),
        found: reference.Typename(0),
      ),
      span: source.Span(start: 0, end: 12),
    ))
}

pub fn typecheck_accepts_matching_port_edge_test() {
  let runtime =
    runtime.new()
    |> runtime.add_output(["math", "out"], reference.Typename(0))
    |> runtime.add_input(["out"], reference.Typename(0))

  let edge =
    ast.Edge(
      from: ast.PortOutput(
        path: ["math", "out"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 8),
      ),
      to: ast.PortInput(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 12, end: 16),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 16),
    )

  assert typecheck_edge.typecheck(edge, runtime) == Ok(Nil)
}
