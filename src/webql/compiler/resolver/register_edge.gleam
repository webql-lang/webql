import webql/compiler/resolver/ast
import webql/compiler/runtime

/// Registers a edge.
pub fn register(runtime: runtime.Runtime, edge: ast.Edge) -> runtime.Runtime {
  runtime.add_edge(runtime, edge.to.reference)
}
