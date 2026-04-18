import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_return
import webql/lang/source

pub fn resolve_resolves_parameter_with_named_type_annotation_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let return_to_resolve =
    parser_ast.Return(
      name: "value",
      typename: parser_ast.Typename(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Ok(value) =
    resolve_return.resolve(registry, return_to_resolve, reference.Return(0))

  assert value
    == ast.Return(
      name: "value",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 7, end: 10),
      ),
      reference: reference.Return(0),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_returns_duplicate_return_for_existing_return_test() {
  let registry = registry.add_return(registry.new(), ["value"])

  let return_to_resolve =
    parser_ast.Return(
      name: "value",
      typename: parser_ast.Typename(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_return.resolve(registry, return_to_resolve, reference.Return(1))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn("value"),
      span: source.Span(start: 0, end: 10),
    )
}
