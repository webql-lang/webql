import webql/graph
import webql/lang/compiler/lowerer
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lowerer_lowers_module_test() {
  let module =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
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
