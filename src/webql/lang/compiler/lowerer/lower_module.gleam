import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_operation
import webql/lang/compiler/resolver/ast

/// Lowers a resolved module into IR.
pub fn lower(module: ast.Module) -> ir.Module {
  ir.Module(operation: lower_operation.lower(module.operation))
}
