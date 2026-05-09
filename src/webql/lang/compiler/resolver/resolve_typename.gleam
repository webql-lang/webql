import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/resolver/diagnostic

/// Resolves typenames in a field.
pub fn resolve(
  environment: environment.Environment,
  typename: ast.Typename,
) -> Result(hir.Typename, diagnostic.Diagnostic) {
  case environment.get_typename(environment, typename.name) {
    Ok(reference) ->
      Ok(hir.Typename(name: typename.name, reference:, span: typename.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(typename.name),
        span: typename.span,
      ))
  }
}
