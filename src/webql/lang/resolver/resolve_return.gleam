import gleam/bool
import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_typename

/// Resolves an output field.
pub fn resolve(
  registry: registry.Registry,
  field: parser_ast.Return,
  reference: reference.Return,
) -> Result(ast.Return, diagnostic.Diagnostic) {
  let parser_ast.Return(name:, typename:, span:) = field

  use <- bool.guard(
    when: dict.has_key(registry.returns, [name]),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(registry, typename))

  Ok(ast.Return(name:, typename:, reference:, span:))
}
