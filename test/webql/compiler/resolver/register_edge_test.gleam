import gleam/dict
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/register_edge
import webql/compiler/runtime
import webql/compiler/source

pub fn register_registers_edge_destination_input_test() {
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

  let runtime = register_edge.register(runtime.new(), edge)
  let runtime.Runtime(edges:, ..) = runtime

  assert edges == dict.from_list([#(reference.Input(0), reference.Edge(0))])
}
