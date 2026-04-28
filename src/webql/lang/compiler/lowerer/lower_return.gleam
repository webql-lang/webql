import webql/lang/compiler/ir
import webql/lang/compiler/resolver/ast

/// Lowers a resolved operation return into an IR output.
pub fn lower(return: ast.Return) -> ir.Return {
  ir.Return(name: return.name, typename: return.typename.name)
}
