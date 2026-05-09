import gleam/bool
import gleam/dict
import gleam/result
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic

/// Resolves a nested operation definition.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  definition: ast.Definition,
  reference: reference.Definition,
  resolve_operation,
) -> Result(#(hir.Definition, context.Context), diagnostic.Diagnostic) {
  let ast.Definition(name:, operation:, span:) = definition

  use <- bool.guard(
    when: result.is_ok(environment.get_node(environment, definition.name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition(definition.name),
      span: definition.span,
    )),
  )

  let context =
    context.Context(
      ..context,
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      bindings: dict.new(),
      edges: dict.new(),
    )

  use #(operation, context) <- result.try(resolve_operation(
    environment,
    context,
    operation,
  ))

  Ok(#(hir.Definition(name:, operation:, reference:, span:), context))
}
