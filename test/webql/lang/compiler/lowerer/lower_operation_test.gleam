import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_operation
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_operation_test() {
  let operation =
    ast.Operation(
      parameters: [
        ast.Parameter(
          name: "in",
          typename: ast.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 4, end: 7),
          ),
          reference: reference.Parameter(0),
          span: source.Span(start: 0, end: 7),
        ),
      ],
      returns: [
        ast.Return(
          name: "out",
          typename: ast.Typename(
            name: "Int",
            reference: reference.Typename(0),
            span: source.Span(start: 15, end: 18),
          ),
          reference: reference.Return(0),
          span: source.Span(start: 10, end: 18),
        ),
      ],
      definitions: [],
      bindings: [
        ast.Binding(
          name: "m",
          value: ast.NodeValue(
            name: "Math",
            reference: reference.Node(0),
            span: source.Span(start: 23, end: 27),
          ),
          reference: reference.Binding(0),
          span: source.Span(start: 19, end: 27),
        ),
      ],
      edges: [
        ast.Edge(
          from: ast.PortOutput(
            path: ["m", "value"],
            reference: reference.Output(0),
            span: source.Span(start: 28, end: 35),
          ),
          to: ast.PortInput(
            path: ["out"],
            reference: reference.Input(0),
            span: source.Span(start: 39, end: 43),
          ),
          reference: reference.Edge(0),
          span: source.Span(start: 28, end: 43),
        ),
      ],
      span: source.Span(start: 0, end: 45),
    )

  assert lower_operation.lower(operation)
    == ir.Operation(
      inputs: [ir.Parameter(name: "in", typename: "Int")],
      outputs: [ir.Return(name: "out", typename: "Int")],
      nodes: [ir.ExternalNode(name: "m", node: "Math")],
      edges: [
        ir.Edge(
          from: ir.Output(path: ["m", "value"]),
          to: ir.Input(path: ["out"]),
        ),
      ],
    )
}
