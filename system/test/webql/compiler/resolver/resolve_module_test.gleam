import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_module
import webql/compiler/source

pub fn resolve_module_wraps_resolved_operation_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let module_to_resolve =
    ast.Module(
      operation: ast.Operation(
        parameters: [],
        returns: [
          ast.Return(
            name: "out",
            typename: ast.Typename(
              name: "Int",
              span: source.Span(start: 8, end: 11),
            ),
            span: source.Span(start: 3, end: 11),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
        span: source.Span(start: 0, end: 14),
      ),
      span: source.Span(start: 0, end: 14),
    )

  let assert Ok(#(module, _context)) =
    resolve_module.resolve(
      schema,
      context.new(),
      module_to_resolve,
      reference.Module(0),
    )

  assert module
    == hir.Module(
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
}
