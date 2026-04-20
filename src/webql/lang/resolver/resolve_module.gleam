import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_operation

/// Resolves a top-level module.
pub fn resolve(
  registry: registry.Registry,
  module: parser_ast.Module,
  reference: reference.Module,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  use operation <- result.try(resolve_operation.resolve(
    registry,
    module.operation,
  ))

  Ok(ast.Module(operation:, reference:, span: module.span))
}
