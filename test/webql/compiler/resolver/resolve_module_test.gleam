import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_module
import webql/compiler/source

pub fn resolve_module_wraps_resolved_operation_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let module_to_resolve =
    parser_ast.Module(
      operation: parser_ast.Operation(
        parameters: [],
        returns: [
          parser_ast.Return(
            name: "out",
            typename: parser_ast.Typename(
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

  let assert Ok(module) =
    resolve_module.resolve(registry, module_to_resolve, reference.Module(0))

  assert module
    == ast.Module(
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
}
