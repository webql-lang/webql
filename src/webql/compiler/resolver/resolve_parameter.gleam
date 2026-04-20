import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_typename

/// Resolves an input field.
pub fn resolve(
  registry: registry.Registry,
  field: parser_ast.Parameter,
  reference: reference.Parameter,
) -> Result(ast.Parameter, diagnostic.Diagnostic) {
  let parser_ast.Parameter(name:, typename:, span:) = field

  use <- bool.guard(
    when: dict.has_key(registry.parameters, [name]),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateParameter(name),
      span:,
    )),
  )

  use typename <- result.try(resolve_typename.resolve(registry, typename))

  Ok(ast.Parameter(name:, typename:, reference:, span:))
}
