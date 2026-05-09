import gleam/bool
import gleam/result
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_typename

/// Resolves an output field.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  field: ast.Return,
  reference: reference.Return,
) -> Result(hir.Return, diagnostic.Diagnostic) {
  let ast.Return(name:, typename:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_return(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(environment, typename))

  Ok(hir.Return(name:, typename:, reference:, span:))
}
