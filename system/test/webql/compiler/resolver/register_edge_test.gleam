import gleam/dict
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_edge
import webql/compiler/source

pub fn register_registers_edge_destination_input_test() {
  let edge =
    hir.Edge(
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

  let context = register_edge.register(context.new(), edge)
  let context.Context(edges:, ..) = context

  assert edges == dict.from_list([#(reference.Input(0), reference.Edge(0))])
}
