import webql/compiler/ir
import webql/compiler/resolver/ast

/// Lowers a resolved operation parameter into an IR input.
pub fn lower(parameter: ast.Parameter) -> ir.Parameter {
  ir.Parameter(name: parameter.name, typename: parameter.typename.name)
}
