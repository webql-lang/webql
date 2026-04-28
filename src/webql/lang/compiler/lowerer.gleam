import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_module
import webql/lang/compiler/resolver/ast

pub opaque type Lowerer {
  Lowerer(module: ast.Module)
}

/// Creates a new lowerer instance from a resolver module.
pub fn new(module: ast.Module) -> Lowerer {
  Lowerer(module:)
}

/// Lowers a resolver module into compiler IR.
pub fn lower(lowerer: Lowerer) -> ir.Module {
  lower_module.lower(lowerer.module)
}
