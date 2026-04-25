import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_return
import webql/compiler/runtime
import webql/compiler/source
import webql/loader/schema

pub fn resolve_resolves_parameter_with_named_type_annotation_test() {
  let schema = schema.add_typename(schema.new(), "Int")

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
    resolve_return.resolve(
      environment.new(schema),
      runtime.new(),
      return_to_resolve,
      reference.Return(0),
    )

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
  let runtime = runtime.add_return(runtime.new(), "value")

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
    resolve_return.resolve(
      environment.new(schema.new()),
      runtime,
      return_to_resolve,
      reference.Return(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn("value"),
      span: source.Span(start: 0, end: 10),
    )
}
