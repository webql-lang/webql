import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_typename

/// Resolves an output field.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  field: parser_ast.Return,
  reference: reference.Return,
) -> Result(ast.Return, diagnostic.Diagnostic) {
  let parser_ast.Return(name:, typename:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_return(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(environment, typename))

  Ok(ast.Return(name:, typename:, reference:, span:))
}
