import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic

/// Resolves a nested operation definition.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  definition: parser_ast.Definition,
  reference: reference.Definition,
  resolve_operation,
) -> Result(#(ast.Definition, context.Context), diagnostic.Diagnostic) {
  let parser_ast.Definition(name:, operation:, span:) = definition

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

  Ok(#(ast.Definition(name:, operation:, reference:, span:), context))
}
