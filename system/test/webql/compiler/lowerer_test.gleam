import webql/compiler/lowerer
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lowerer_lowers_module_test() {
  let module =
    hir.Module(
      operation: hir.Operation(
        parameters: [],
        returns: [
          hir.Return(
            name: "out",
            typename: hir.Typename(
              name: "Int",
              reference: reference.Typename(0),
              span: source.Span(start: 8, end: 11),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      reference: reference.Module(0),
      span: source.Span(start: 0, end: 14),
    )

  let lowerer = lowerer.new(module)

  assert lowerer.lower(lowerer)
    == graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [graph.Return(name: "out", typename: "Int")],
        nodes: [],
        edges: [],
      ),
    )
}
