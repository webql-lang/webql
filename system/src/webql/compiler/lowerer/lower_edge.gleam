import webql/compiler/lowerer/lower_source
import webql/compiler/lowerer/lower_target
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved edge into an IR edge.
pub fn lower(edge: hir.Edge) -> graph.Edge {
  graph.Edge(
    source: lower_source.lower(edge.source),
    target: lower_target.lower(edge.target),
  )
}
