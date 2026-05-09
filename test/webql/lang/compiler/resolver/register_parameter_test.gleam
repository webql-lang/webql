import gleam/dict
import webql/lang/compiler/context
import webql/lang/compiler/hir
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/register_parameter
import webql/lang/compiler/source

pub fn register_registers_parameter_and_output_test() {
  let parameter =
    hir.Parameter(
      name: "in",
      typename: hir.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 4, end: 7),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 7),
    )

  let context = register_parameter.register(context.new(), parameter)
  let context.Context(parameters:, outputs:, ..) = context

  assert parameters == dict.from_list([#("in", reference.Parameter(0))])
  assert outputs
    == dict.from_list([
      #(["in"], #(reference.Output(0), reference.Typename(0))),
    ])
}
