import webql/compiler/lowerer/lower_document
import webql/compiler/resolver/hir
import webql/graph

pub opaque type Lowerer {
  Lowerer(document: hir.Document)
}

/// Creates a new lowerer instance from a resolver document.
pub fn new(document: hir.Document) -> Lowerer {
  Lowerer(document:)
}

/// Lowers a resolver document into compiler IR.
pub fn lower(lowerer: Lowerer) -> graph.Graph {
  lower_document.lower(lowerer.document)
}
