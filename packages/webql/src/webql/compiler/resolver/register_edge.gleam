import webql/compiler/context
import webql/compiler/resolver/hir

/// Registers a edge.
pub fn register(context: context.Context, edge: hir.Edge) -> context.Context {
  context.add_edge(context, edge.target.reference)
}
