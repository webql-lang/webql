import gleam/dict
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/register_return
import webql/compiler/resolver/runtime
import webql/compiler/source

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

  let runtime = register_return.register(runtime.new(), return)
  let runtime.Runtime(returns:, inputs:, ..) = runtime

  assert returns == dict.from_list([#("out", reference.Return(0))])
  assert inputs
    == dict.from_list([
      #(["out"], #(reference.Input(0), reference.Typename(0))),
    ])
}
