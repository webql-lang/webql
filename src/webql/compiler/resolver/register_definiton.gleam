import webql/compiler/context
import webql/compiler/resolver/hir

/// Registers a definition.
pub fn register(
  context: context.Context,
  definition: hir.Definition,
  sub_context: context.Context,
) -> context.Context {
  context
  |> context.add_definition(definition.name)
  |> context.add_context(definition.reference, sub_context)
}
