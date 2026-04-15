import gleam/dict
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/registry

/// Resolves annotations in a field.
pub fn resolve(
  registry: registry.Registry,
  annotation: parser_ast.Typename,
) -> Result(ast.Typename, diagnostic.Diagnostic) {
  case dict.get(registry.typenames, annotation.name) {
    Ok(reference) ->
      Ok(ast.Typename(name: annotation.name, reference:, span: annotation.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(annotation.name),
        span: annotation.span,
      ))
  }
}
