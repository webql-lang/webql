import webql/lang/compiler/environment
import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/resolver/diagnostic

/// Resolves typenames in a field.
pub fn resolve(
  environment: environment.Environment,
  typename: parser_ast.Typename,
) -> Result(ast.Typename, diagnostic.Diagnostic) {
  case environment.get_typename(environment, typename.name) {
    Ok(reference) ->
      Ok(ast.Typename(name: typename.name, reference:, span: typename.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(typename.name),
        span: typename.span,
      ))
  }
}
