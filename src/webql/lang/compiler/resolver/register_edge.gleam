import webql/lang/compiler/context
import webql/lang/compiler/resolver/ast

/// Registers a edge.
pub fn register(context: context.Context, edge: ast.Edge) -> context.Context {
  context.add_edge(context, edge.to.reference)
}
