import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_typename

/// Resolves an input field.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  field: ast.Parameter,
  reference: reference.Parameter,
) -> Result(hir.Parameter, diagnostic.Diagnostic) {
  let ast.Parameter(name:, typename:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_parameter(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateParameter(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(environment, typename))

  Ok(hir.Parameter(name:, typename:, reference:, span:))
}
