import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_typename

/// Resolves an input field.
pub fn resolve(
  registry: registry.Registry,
  field: parser_ast.Input,
  reference: reference.Input,
) -> Result(ast.Input, diagnostic.Diagnostic) {
  let parser_ast.Input(name:, typename:, span:) = field
  use typename <- result.try(resolve_typename.resolve(registry, typename))

  Ok(ast.Input(name:, typename:, reference:, span:))
}
