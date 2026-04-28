import gleam/dict
import webql/lang/compiler/context
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/register_return
import webql/lang/compiler/source

pub fn register_registers_return_and_input_test() {
  let return =
    ast.Return(
      name: "out",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
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
      #(["out"], #(reference.Input(0), reference.Typename(0))),
    ])
}
