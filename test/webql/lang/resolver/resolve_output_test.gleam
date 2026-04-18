import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_output
import webql/lang/source

pub fn resolve_resolves_parameter_with_named_type_annotation_test() {
  let registry = registry.add_typename(registry.new(), "Int")

  let parameter_to_resolve =
    parser_ast.Return(
      name: "value",
      typename: parser_ast.Typename(
        name: "Int",
        span: source.Span(start: 7, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Ok(parameter) =
    resolve_output.resolve(registry, parameter_to_resolve, reference.Output(0))

  assert parameter
    == ast.Output(
      name: "value",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 7, end: 10),
      ),
      reference: reference.Output(0),
      span: source.Span(start: 0, end: 10),
    )
}
