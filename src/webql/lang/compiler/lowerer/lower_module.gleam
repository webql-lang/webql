import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_operation

/// Lowers a resolved module into IR.
pub fn lower(module: hir.Module) -> graph.Module {
  graph.Module(operation: lower_operation.lower(module.operation))
}
