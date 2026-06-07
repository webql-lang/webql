import gleam/dict
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_return
import webql/compiler/source

pub fn register_registers_return_and_input_test() {
  let return =
    hir.Return(
      name: "out",
      port: hir.Port(
        name: "Int",
        reference: reference.Port(0),
        span: source.Span(start: 5, end: 8),
      ),
      reference: reference.Return(0),
      span: source.Span(start: 0, end: 8),
    )

  let context = register_return.register(context.new(), return)
  let context.Context(returns:, inputs:, ..) = context

  assert returns == dict.from_list([#("out", reference.Return(0))])
  assert inputs
    == dict.from_list([
      #(["out"], #(reference.Input(0), reference.Port(0))),
    ])
}
