import gleam/bool
import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_value

/// Resolves a binding declaration.
pub fn resolve(
  registry: registry.Registry,
  binding: parser_ast.Binding,
  reference: reference.Binding,
) -> Result(ast.Binding, diagnostic.Diagnostic) {
  let parser_ast.Binding(name:, value:, span:) = binding

  use <- bool.guard(
    when: dict.has_key(registry.bindings, [name]),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateBinding(name),
      span:,
    )),
  )

  use value <- result.try(resolve_value.resolve(registry, value))

  Ok(ast.Binding(name:, value:, reference:, span:))
}
