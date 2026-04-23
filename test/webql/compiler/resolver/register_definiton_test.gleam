import gleam/dict
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/register_definiton
import webql/compiler/resolver/runtime
import webql/compiler/source

pub fn register_registers_definition_and_nested_runtime_test() {
  let definition =
    ast.Definition(
      name: "Inner",
      operation: ast.Operation(
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

  let sub_runtime = runtime.add_return(runtime.new(), "out")
  let runtime = register_definiton.register(runtime.new(), definition, sub_runtime)
  let runtime.Runtime(definitions:, runtimes:, ..) = runtime

  assert definitions == dict.from_list([#("Inner", reference.Definition(0))])
  assert runtimes == dict.from_list([#(reference.Definition(0), sub_runtime)])
}
