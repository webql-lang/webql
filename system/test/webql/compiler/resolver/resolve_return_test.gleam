import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_return
import webql/compiler/source

pub fn resolve_resolves_return_with_named_type_annotation_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let return_to_resolve =
    ast.Return(
      name: "value",
      port: ast.Port(name: "Int", span: source.Span(start: 7, end: 10)),
      span: source.Span(start: 0, end: 10),
    )

  let assert Ok(value) =
    resolve_return.resolve(
      schema,
      context.new(),
      return_to_resolve,
      reference.Return(0),
    )

  assert value
    == hir.Return(
      name: "value",
      port: hir.Port(
        name: "Int",
        reference: reference.Port(0),
        span: source.Span(start: 7, end: 10),
      ),
      reference: reference.Return(0),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_returns_unknown_type_for_missing_return_annotation_test() {
  let schema = environment.new()

  let return_to_resolve =
    ast.Return(
      name: "value",
      port: ast.Port(name: "Int", span: source.Span(start: 7, end: 10)),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_return.resolve(
      schema,
      context.new(),
      return_to_resolve,
      reference.Return(0),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownPort("Int"),
      span: source.Span(start: 7, end: 10),
    )
}

pub fn resolve_returns_duplicate_return_for_existing_return_test() {
  let context = context.add_return(context.new(), "value")

  let return_to_resolve =
    ast.Return(
      name: "value",
      port: ast.Port(name: "Int", span: source.Span(start: 7, end: 10)),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_return.resolve(
      environment.new(),
      context,
      return_to_resolve,
      reference.Return(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn("value"),
      span: source.Span(start: 0, end: 10),
    )
}
