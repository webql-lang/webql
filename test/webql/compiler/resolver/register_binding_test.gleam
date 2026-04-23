import gleam/dict
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/register_binding
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema
import webql/compiler/source

pub fn register_registers_primitive_binding_name_only_test() {
  let binding =
    ast.Binding(
      name: "count",
      value: ast.PrimitiveValue(
        value: ast.Int(value: 123, span: source.Span(start: 8, end: 11)),
        typename: reference.Typename(0),
        span: source.Span(start: 8, end: 11),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 11),
    )

  let runtime = register_binding.register(schema.new(), runtime.new(), binding)
  let runtime.Runtime(bindings:, inputs:, outputs:, ..) = runtime

  assert bindings == dict.from_list([#("count", reference.Binding(0))])
  assert inputs == dict.new()
  assert outputs == dict.new()
}

pub fn register_registers_node_binding_ports_from_schema_test() {
  let schema =
    schema.new()
    |> schema.add_node("Math")
    |> schema.add_inputs(reference.Node(0), [#("left", reference.Typename(0))])
    |> schema.add_outputs(reference.Node(0), [#("value", reference.Typename(0))])

  let binding =
    ast.Binding(
      name: "math",
      value: ast.NodeValue(
        name: "Math",
        reference: reference.Node(0),
        span: source.Span(start: 7, end: 11),
      ),
      reference: reference.Binding(0),
      span: source.Span(start: 0, end: 11),
    )

  let runtime = register_binding.register(schema, runtime.new(), binding)
  let runtime.Runtime(bindings:, inputs:, outputs:, ..) = runtime

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
