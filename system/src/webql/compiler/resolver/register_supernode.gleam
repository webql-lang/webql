import webql/compiler/context
import webql/compiler/resolver/hir

/// Registers a supernode.
pub fn register(
  context: context.Context,
  supernode: hir.Node,
  sub_context: context.Context,
) -> context.Context {
  let assert hir.Supernode(name:, reference:, ..) = supernode

  context
  |> context.add_supernode(name)
  |> context.add_context(reference, sub_context)
}
