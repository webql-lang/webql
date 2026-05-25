import webql/compiler/context
import webql/compiler/resolver/hir

/// Registers a return.
pub fn register(
  context: context.Context,
  return: hir.Return,
) -> context.Context {
  context
  |> context.add_return(return.name)
  |> context.add_input([return.name], return.typename.reference)
}
