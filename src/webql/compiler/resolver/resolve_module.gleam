import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_operation

/// Resolves a top-level module.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  module: parser_ast.Module,
  reference: reference.Module,
) -> Result(#(ast.Module, context.Context), diagnostic.Diagnostic) {
  use #(operation, context) <- result.try(resolve_operation.resolve(
    environment,
    context,
    module.operation,
  ))

  Ok(#(ast.Module(operation:, reference:, span: module.span), context))
}
