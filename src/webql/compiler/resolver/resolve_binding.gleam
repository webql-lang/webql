import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_value

/// Resolves a binding declaration.
pub fn resolve(
  registry: registry.Registry,
  binding: parser_ast.Binding,
  reference: reference.Binding,
) -> Result(ast.Binding, diagnostic.Diagnostic) {
  let parser_ast.Binding(name:, value:, span:) = binding

  use <- bool.guard(
    when: dict.has_key(registry.bindings, name),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateBinding(name),
      span:,
    )),
  )

  use value <- result.try(resolve_value.resolve(registry, value))

  Ok(ast.Binding(name:, value:, reference:, span:))
}
