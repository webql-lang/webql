import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_annotation
import webql/lang/source

pub fn resolve_named_type_annotation_test() {
  let registry = registry.new(typenames: ["Int"])

  let annotation_to_resolve =
    parser_ast.NamedTypeAnnotation(
      name: "Int",
      span: source.Span(start: 0, end: 3),
    )

  let assert Ok(annotation) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert annotation
    == ast.NamedTypeAnnotation(
      typename: reference.Type(0),
      name: "Int",
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_annotation_test() {
  let registry = registry.new(typenames: [])

  let annotation_to_resolve =
    parser_ast.NamedTypeAnnotation(
      name: "Int",
      span: source.Span(start: 0, end: 3),
    )

  let assert Error(error) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Int"),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_list_type_annotation_of_named_type_test() {
  let registry = registry.new(typenames: ["Int"])

  let annotation_to_resolve =
    parser_ast.ListTypeAnnotation(
      of: parser_ast.NamedTypeAnnotation(
        name: "Int",
        span: source.Span(start: 1, end: 4),
      ),
      span: source.Span(start: 0, end: 5),
    )

  let assert Ok(annotation) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert annotation
    == ast.ListTypeAnnotation(
      typename: reference.ListType(reference.Type(0)),
      of: ast.NamedTypeAnnotation(
        typename: reference.Type(0),
        name: "Int",
        span: source.Span(start: 1, end: 4),
      ),
      span: source.Span(start: 0, end: 5),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_in_list_annotation_test() {
  let registry = registry.new(typenames: [])

  let annotation_to_resolve =
    parser_ast.ListTypeAnnotation(
      of: parser_ast.NamedTypeAnnotation(
        name: "Int",
        span: source.Span(start: 1, end: 4),
      ),
      span: source.Span(start: 0, end: 5),
    )

  let assert Error(error) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Int"),
      span: source.Span(start: 1, end: 4),
    )
}

pub fn resolve_nested_list_type_annotation_test() {
  let registry = registry.new(typenames: ["Int"])

  let annotation_to_resolve =
    parser_ast.ListTypeAnnotation(
      of: parser_ast.ListTypeAnnotation(
        of: parser_ast.NamedTypeAnnotation(
          name: "Int",
          span: source.Span(start: 2, end: 5),
        ),
        span: source.Span(start: 1, end: 6),
      ),
      span: source.Span(start: 0, end: 7),
    )

  let assert Ok(annotation) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert annotation
    == ast.ListTypeAnnotation(
      typename: reference.ListType(reference.ListType(reference.Type(0))),
      of: ast.ListTypeAnnotation(
        typename: reference.ListType(reference.Type(0)),
        of: ast.NamedTypeAnnotation(
          typename: reference.Type(0),
          name: "Int",
          span: source.Span(start: 2, end: 5),
        ),
        span: source.Span(start: 1, end: 6),
      ),
      span: source.Span(start: 0, end: 7),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_in_nested_list_annotation_test() {
  let registry = registry.new(typenames: [])

  let annotation_to_resolve =
    parser_ast.ListTypeAnnotation(
      of: parser_ast.ListTypeAnnotation(
        of: parser_ast.NamedTypeAnnotation(
          name: "Int",
          span: source.Span(start: 2, end: 5),
        ),
        span: source.Span(start: 1, end: 6),
      ),
      span: source.Span(start: 0, end: 7),
    )

  let assert Error(error) =
    resolve_annotation.resolve(registry, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownType("Int"),
      span: source.Span(start: 2, end: 5),
    )
}
