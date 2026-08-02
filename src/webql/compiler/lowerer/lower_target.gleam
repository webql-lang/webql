import webql/compiler/resolver
import webql/graph

/// Lowers a resolved target into an IR target.
pub fn lower(target: resolver.Target) -> graph.Target {
  graph.Input(path: target.path)
}
