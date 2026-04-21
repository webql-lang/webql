import gleam/dict
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/registry

/// Resolves typenames in a field.
pub fn resolve(
  registry: registry.Registry,
  typename: parser_ast.Typename,
) -> Result(ast.Typename, diagnostic.Diagnostic) {
  case dict.get(registry.typenames, typename.name) {
    Ok(reference) ->
      Ok(ast.Typename(name: typename.name, reference:, span: typename.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(typename.name),
        span: typename.span,
      ))
  }
}
