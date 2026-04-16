import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_parameter
import webql/lang/source

pub fn resolve_resolves_parameter_with_named_type_annotation_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let parameter_to_resolve =
    parser_ast.Parameter(
      name: "value",
      typename: parser_ast.Typename(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Ok(parameter) =
    resolve_parameter.resolve(
      registry,
      parameter_to_resolve,
      reference.Access(0),
    )

  assert parameter
    == ast.Parameter(
      name: "value",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 7, end: 10),
      ),
      reference: reference.Access(0),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_returns_unknown_type_for_missing_parameter_annotation_test() {
  let registry = registry.new()

  let parameter_to_resolve =
    parser_ast.Parameter(
      name: "value",
      typename: parser_ast.Typename(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_parameter.resolve(
      registry,
      parameter_to_resolve,
      reference.Access(0),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 7, end: 10),
    )
}
