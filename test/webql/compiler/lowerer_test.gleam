import webql/compiler/ir
import webql/compiler/lowerer
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/source

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
    == ir.Module(
      operation: ir.Operation(
        inputs: [],
        outputs: [ir.Return(name: "out", typename: "Int")],
        nodes: [],
        edges: [],
      ),
    )
}
