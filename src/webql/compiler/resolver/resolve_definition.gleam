import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/reference
import webql/compiler/resolver/runtime
import webql/compiler/resolver/schema

/// Resolves a nested operation definition.
pub fn resolve(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  definition: parser_ast.Definition,
  reference: reference.Definition,
  resolve_operation,
) -> Result(#(ast.Definition, runtime.Runtime), diagnostic.Diagnostic) {
  let parser_ast.Definition(name:, operation:, span:) = definition

  use <- bool.guard(
    when: result.is_ok(runtime.get_definition(runtime, definition.name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateDefinition(definition.name),
      span: definition.span,
    )),
  )

  let runtime =
    runtime.Runtime(
      ..runtime,
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      bindings: dict.new(),
      edges: dict.new(),
    )

  use operation <- result.try(resolve_operation(schema, runtime, operation))

  Ok(#(ast.Definition(name:, operation:, reference:, span:), runtime))
}
