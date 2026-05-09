import gleam/dict
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/register_binding
import webql/lang/compiler/source

pub fn register_registers_node_binding_ports_from_schema_test() {
  let schema =
    environment.new()
    |> environment.add_node("Math")
    |> environment.add_inputs(reference.Node(0), [
      #("left", reference.Typename(0)),
    ])
    |> environment.add_outputs(reference.Node(0), [
      #("value", reference.Typename(0)),
    ])

  let binding =
    hir.Binding(
      name: "math",
      value: hir.NodeValue(
        name: "Math",
        reference: reference.Node(0),
        span: source.Span(start: 7, end: 11),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 11),
    )

  let context = register_binding.register(schema, context.new(), binding)
  let context.Context(bindings:, inputs:, outputs:, ..) = context

  assert bindings == dict.from_list([#("math", reference.Binding(0))])
  assert inputs
    == dict.from_list([
      #(["math", "left"], #(reference.Input(0), reference.Typename(0))),
    ])
  assert outputs
    == dict.from_list([
      #(["math", "value"], #(reference.Output(0), reference.Typename(0))),
    ])
}
