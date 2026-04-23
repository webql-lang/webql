import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/schema

/// Resolves typenames in a field.
pub fn resolve(
  schema: schema.Schema,
  typename: parser_ast.Typename,
) -> Result(ast.Typename, diagnostic.Diagnostic) {
  case schema.get_typename(schema, typename.name) {
    Ok(reference) ->
      Ok(ast.Typename(name: typename.name, reference:, span: typename.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(typename.name),
        span: typename.span,
      ))
  }
}
