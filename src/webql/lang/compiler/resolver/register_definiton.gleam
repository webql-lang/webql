import webql/lang/compiler/context
import webql/lang/compiler/resolver/ast

/// Registers a definition.
pub fn register(
  context: context.Context,
  definition: ast.Definition,
  sub_context: context.Context,
) -> context.Context {
  context
  |> context.add_definition(definition.name)
  |> context.add_context(definition.reference, sub_context)
}
