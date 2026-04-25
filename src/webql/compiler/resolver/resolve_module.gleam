import gleam/result
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_operation
import webql/compiler/runtime

/// Resolves a top-level module.
pub fn resolve(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  module: parser_ast.Module,
  reference: reference.Module,
) -> Result(#(ast.Module, runtime.Runtime), diagnostic.Diagnostic) {
  use #(operation, runtime) <- result.try(resolve_operation.resolve(
    environment,
    runtime,
    module.operation,
  ))

  Ok(#(ast.Module(operation:, reference:, span: module.span), runtime))
}
