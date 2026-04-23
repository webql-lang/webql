import gleam/dict
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/register_parameter
import webql/compiler/resolver/runtime
import webql/compiler/source

pub fn register_registers_parameter_and_output_test() {
  let parameter =
    ast.Parameter(
      name: "in",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 4, end: 7),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 7),
    )

  let runtime = register_parameter.register(runtime.new(), parameter)
  let runtime.Runtime(parameters:, outputs:, ..) = runtime

  assert parameters == dict.from_list([#("in", reference.Parameter(0))])
  assert outputs
    == dict.from_list([
      #(["in"], #(reference.Output(0), reference.Typename(0))),
    ])
}
