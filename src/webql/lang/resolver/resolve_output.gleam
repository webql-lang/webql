import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_typename

/// Resolves an output field.
pub fn resolve(
  registry: registry.Registry,
  field: parser_ast.Output,
  reference: reference.Output,
) -> Result(ast.Output, diagnostic.Diagnostic) {
  let parser_ast.Output(name:, typename:, span:) = field
  use typename <- result.try(resolve_typename.resolve(registry, typename))

  Ok(ast.Output(name:, typename:, reference:, span:))
}
