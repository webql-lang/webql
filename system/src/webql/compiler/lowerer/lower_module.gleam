import webql/compiler/lowerer/lower_operation
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved module into IR.
pub fn lower(module: hir.Module) -> graph.Graph {
  lower_operation.lower(module.operation)
}
