import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_field
import webql/lang/source

pub fn resolve_resolves_field_with_named_type_annotation_test() {
  let registry = registry.new(typenames: ["Int"])

  let field_to_resolve =
    parser_ast.Field(
      name: "value",
      annotation: parser_ast.NamedTypeAnnotation(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Ok(field) =
    resolve_field.resolve(registry, field_to_resolve, reference.Port(0))

  assert field
    == ast.Field(
      name: "value",
      port: reference.Port(0),
      annotation: ast.NamedTypeAnnotation(
        typename: reference.Type(0),
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_returns_unknown_type_for_missing_field_annotation_test() {
  let registry = registry.new(typenames: [])

  let field_to_resolve =
    parser_ast.Field(
      name: "value",
      annotation: parser_ast.NamedTypeAnnotation(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_field.resolve(registry, field_to_resolve, reference.Port(0))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Int"),
      span: source.Span(start: 7, end: 10),
    )
}
