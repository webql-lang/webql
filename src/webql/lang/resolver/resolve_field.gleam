import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_annotation

/// Resolves a field.
pub fn resolve(
  registry: registry.Registry,
  field: parser_ast.Parameter,
  port: reference.Port,
) -> Result(ast.Field, diagnostic.Diagnostic) {
  let parser_ast.Parameter(name:, typename:, span:) = field
  use annotation <- result.try(resolve_annotation.resolve(registry, typename))

  Ok(ast.Field(name:, port:, annotation:, span:))
}
