import webql/compiler/lowerer/lower_graph
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved document into IR.
pub fn lower(document: hir.Document) -> graph.Graph {
  lower_graph.lower(document.graph)
}
