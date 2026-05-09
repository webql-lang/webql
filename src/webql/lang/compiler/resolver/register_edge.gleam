import webql/lang/compiler/context
import webql/lang/compiler/hir

/// Registers a edge.
pub fn register(context: context.Context, edge: hir.Edge) -> context.Context {
  context.add_edge(context, edge.to.reference)
}
