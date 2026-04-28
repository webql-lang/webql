import webql/graph/ir
import webql/lang/compiler/lowerer/lower_edge
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_port_edge_test() {
  let edge =
    ast.Edge(
      from: ast.PortOutput(
        path: ["m", "value"],
        reference: reference.Output(0),
        span: source.Span(start: 0, end: 7),
      ),
      to: ast.PortInput(
        path: ["out"],
        reference: reference.Input(0),
        span: source.Span(start: 11, end: 15),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 15),
    )

  assert lower_edge.lower(edge)
    == ir.Edge(
      from: ir.Output(path: ["m", "value"]),
      to: ir.Input(path: ["out"]),
    )
}

pub fn lower_primitive_edge_output_test() {
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
        path: ["m", "left"],
        reference: reference.Input(0),
        span: source.Span(start: 5, end: 11),
      ),
      reference: reference.Edge(0),
      span: source.Span(start: 0, end: 11),
    )

  assert lower_edge.lower(edge)
    == ir.Edge(
      from: ir.PrimitiveOutput(value: ir.IntPrimitive(1)),
      to: ir.Input(path: ["m", "left"]),
    )
}
