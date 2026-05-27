import gleam/dict
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_parameter
import webql/compiler/source

pub fn register_registers_parameter_and_output_test() {
  let parameter =
    hir.Parameter(
      name: "in",
      port: hir.Port(
        name: "Int",
        reference: reference.Port(0),
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
      #(["in"], #(reference.Output(0), reference.Port(0))),
    ])
}
