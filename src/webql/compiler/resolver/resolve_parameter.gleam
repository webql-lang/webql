import gleam/bool
import gleam/result
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_typename
import webql/compiler/runtime

/// Resolves an input field.
pub fn resolve(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  field: parser_ast.Parameter,
  reference: reference.Parameter,
) -> Result(ast.Parameter, diagnostic.Diagnostic) {
  let parser_ast.Parameter(name:, typename:, span:) = field

  use <- bool.guard(
    when: result.is_ok(runtime.get_parameter(runtime, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateParameter(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(environment, typename))

  Ok(ast.Parameter(name:, typename:, reference:, span:))
}
