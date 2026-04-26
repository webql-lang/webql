import webql/compiler/ir
import webql/compiler/lowerer/lower_operation
import webql/compiler/resolver/ast

/// Lowers a resolved module into IR.
pub fn lower(module: ast.Module) -> ir.Module {
  ir.Module(operation: lower_operation.lower(module.operation))
}
