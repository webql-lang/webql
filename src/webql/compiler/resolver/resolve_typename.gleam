import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

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
