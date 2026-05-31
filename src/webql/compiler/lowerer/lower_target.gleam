import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved target into an IR target.
pub fn lower(target: hir.Target) -> graph.Target {
  graph.Input(path: target.path)
}
