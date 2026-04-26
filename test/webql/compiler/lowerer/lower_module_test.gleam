import webql/compiler/ir
import webql/compiler/lowerer/lower_module
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/source

pub fn lower_module_test() {
  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 2),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 2),
    )

  assert lower_module.lower(module)
    == ir.Module(
      operation: ir.Operation(inputs: [], outputs: [], nodes: [], edges: []),
    )
}
