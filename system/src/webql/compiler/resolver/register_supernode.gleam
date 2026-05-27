import webql/compiler/context
import webql/compiler/reference

/// Registers a supernode.
pub fn register(
  context: context.Context,
  name: String,
  reference: reference.Supernode,
  sub_context: context.Context,
) -> context.Context {
  context
  |> context.add_supernode(name)
  |> context.add_context(reference, sub_context)
}
