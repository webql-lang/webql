import gleam/dict
import webql/lang/compiler/context
import webql/lang/compiler/hir
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/register_definiton
import webql/lang/compiler/source

pub fn register_registers_definition_and_nested_context_test() {
  let definition =
    hir.Definition(
      name: "Inner",
      operation: hir.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 8, end: 12),
      ),
      reference: reference.Definition(0),
      span: source.Span(start: 0, end: 12),
    )

  let sub_context = context.add_return(context.new(), "out")
  let context =
    register_definiton.register(context.new(), definition, sub_context)
  let context.Context(definitions:, contexts:, ..) = context

  assert definitions == dict.from_list([#("Inner", reference.Definition(0))])
  assert contexts == dict.from_list([#(reference.Definition(0), sub_context)])
}
