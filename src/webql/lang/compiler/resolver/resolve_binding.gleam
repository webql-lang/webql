import gleam/bool
import gleam/result
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_value

/// Resolves a binding declaration.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  binding: ast.Binding,
  reference: reference.Binding,
) -> Result(hir.Binding, diagnostic.Diagnostic) {
  let ast.Binding(name:, value:, span:) = binding

  use <- bool.guard(
    when: result.is_ok(context.get_binding(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateBinding(name),
      span:,
    )),
  )

  use value <- result.try(resolve_value.resolve(environment, value))

  Ok(hir.Binding(name:, value:, reference:, span:))
}
