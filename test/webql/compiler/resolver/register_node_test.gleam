import gleam/dict
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_node
import webql/compiler/source

pub fn register_registers_node_ports_from_schema_test() {
  let schema =
    environment.new()
    |> environment.add_node("Math")
    |> environment.add_inputs(reference.Kind(0), [
      #("left", reference.Port(0)),
    ])
    |> environment.add_outputs(reference.Kind(0), [
      #("value", reference.Port(0)),
    ])

  let node =
    hir.Node(
      name: "math",
      node: "Math",
      kind: reference.Kind(0),
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 11),
    )

  let context = register_node.register(schema, context.new(), node)
  let context.Context(nodes:, inputs:, outputs:, ..) = context

  assert nodes == dict.from_list([#("math", reference.Node(0))])
  assert inputs
    == dict.from_list([
      #(["math", "left"], #(reference.Input(0), reference.Port(0))),
    ])
  assert outputs
    == dict.from_list([
      #(["math", "value"], #(reference.Output(0), reference.Port(0))),
    ])
}
