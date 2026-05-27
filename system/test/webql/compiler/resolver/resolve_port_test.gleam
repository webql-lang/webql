import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_port
import webql/compiler/source

pub fn resolve_named_type_annotation_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let annotation_to_resolve =
    ast.Port(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Ok(annotation) =
    resolve_port.resolve(schema, annotation_to_resolve)

  assert annotation
    == hir.Port(
      name: "Int",
      reference: reference.Port(0),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn resolve_returns_unknown_type_for_missing_named_type_annotation_test() {
  let schema = environment.new()

  let annotation_to_resolve =
    ast.Port(name: "Int", span: source.Span(start: 0, end: 3))

  let assert Error(error) = resolve_port.resolve(schema, annotation_to_resolve)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownPort("Int"),
      span: source.Span(start: 0, end: 3),
    )
}
