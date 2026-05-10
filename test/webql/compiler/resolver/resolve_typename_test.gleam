import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_typename
import webql/compiler/source

pub fn resolve_named_type_annotation_test() {
  let schema = environment.add_typename(environment.new(), "Int")

  let annotation_to_resolve =
    ast.Typename(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Ok(annotation) =
    resolve_typename.resolve(schema, annotation_to_resolve)

  assert annotation
    == hir.Typename(
      name: "Int",
      reference: reference.Typename(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_annotation_test() {
  let schema = environment.new()

  let annotation_to_resolve =
    ast.Typename(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Error(error) =
    resolve_typename.resolve(schema, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
