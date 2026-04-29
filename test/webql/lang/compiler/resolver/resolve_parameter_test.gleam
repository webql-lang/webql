import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_parameter
import webql/lang/compiler/source

pub fn resolve_resolves_parameter_with_named_type_annotation_test() {
  let schema = environment.add_typename(environment.new(), "Int")

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
      schema,
      context.new(),
      parameter_to_resolve,
      reference.Parameter(0),
    )

  assert parameter
    == ast.Parameter(
      name: "value",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 7, end: 10),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_returns_unknown_type_for_missing_parameter_annotation_test() {
  let schema = environment.new()

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
      schema,
      context.new(),
      parameter_to_resolve,
      reference.Parameter(0),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnknownTypename("Int"),
      span: source.Span(start: 7, end: 10),
    )
}

pub fn resolve_returns_duplicate_parameter_for_existing_parameter_test() {
  let context = context.add_parameter(context.new(), "value")

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
      environment.new(),
      context,
      parameter_to_resolve,
      reference.Parameter(1),
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateParameter("value"),
      span: source.Span(start: 0, end: 10),
    )
}
