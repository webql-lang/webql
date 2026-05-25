import webql/compiler/lowerer/lower_input
import webql/compiler/lowerer/lower_output
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved edge into an IR edge.
pub fn lower(edge: hir.Edge) -> graph.Edge {
  graph.Edge(
    from: lower_output.lower(edge.from),
    to: lower_input.lower(edge.to),
  )
}
