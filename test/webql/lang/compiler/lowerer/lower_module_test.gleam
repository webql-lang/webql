import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_module
import webql/lang/compiler/reference
import webql/lang/compiler/source

pub fn lower_module_test() {
  let module =
    hir.Module(
      operation: hir.Operation(
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
    == graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
      ),
    )
}
