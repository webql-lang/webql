import webql/compiler/lowerer/lower_document
import webql/compiler/resolver
import webql/graph

pub opaque type Lowerer {
  Lowerer(document: resolver.Document)
}

/// Creates a new lowerer instance from a resolver document.
pub fn new(document: resolver.Document) -> Lowerer {
  Lowerer(document:)
}

/// Lowers a resolver document into compiler IR.
pub fn lower(lowerer: Lowerer) -> graph.Graph {
  lower_document.lower(lowerer.document)
}
