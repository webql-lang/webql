import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_typename
import webql/lang/source

pub fn resolve_named_type_annotation_test() {
  let registry = registry.new(typenames: ["Int"], nodes: [])

  let annotation_to_resolve =
    parser_ast.Typename(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Ok(annotation) =
    resolve_typename.resolve(registry, annotation_to_resolve)

  assert annotation
    == ast.Typename(
      name: "Int",
      reference: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_annotation_test() {
  let registry = registry.new(typenames: [], nodes: [])

  let annotation_to_resolve =
    parser_ast.Typename(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Error(error) =
    resolve_typename.resolve(registry, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
