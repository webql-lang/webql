import webql/compiler/lowerer/lower_module
import webql/compiler/resolver/hir
import webql/graph

pub opaque type Lowerer {
  Lowerer(module: hir.Module)
}

/// Creates a new lowerer instance from a resolver module.
pub fn new(module: hir.Module) -> Lowerer {
  Lowerer(module:)
}

/// Lowers a resolver module into compiler IR.
pub fn lower(lowerer: Lowerer) -> graph.Module {
  lower_module.lower(lowerer.module)
}
