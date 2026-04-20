import gleam/bool
import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry

/// Resolves a nested operation definition.
pub fn resolve(
  registry: registry.Registry,
  definition: parser_ast.Definition,
  reference: reference.Definition,
  resolve_operation,
) -> Result(#(ast.Definition, registry.Registry), diagnostic.Diagnostic) {
  let parser_ast.Definition(name:, operation:, span:) = definition

  use <- bool.guard(
    when: dict.has_key(registry.definitions, definition.name),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition(definition.name),
      span: definition.span,
    )),
  )

  let registry =
    registry.Registry(
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      definitions: registry.definitions,
      bindings: dict.new(),
      edges: dict.new(),
      nodes: registry.nodes,
      typenames: registry.typenames,
    )

  use operation <- result.try(resolve_operation(registry, operation))

  Ok(#(ast.Definition(name:, operation:, reference:, span:), registry))
}
