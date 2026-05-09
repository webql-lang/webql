import gleam/result
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_operation

/// Resolves a top-level module.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  module: ast.Module,
  reference: reference.Module,
) -> Result(#(hir.Module, context.Context), diagnostic.Diagnostic) {
  use #(operation, context) <- result.try(resolve_operation.resolve(
    environment,
    context,
    module.operation,
  ))

  Ok(#(hir.Module(operation:, reference:, span: module.span), context))
}
