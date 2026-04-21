import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_operation

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
