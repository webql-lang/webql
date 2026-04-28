import webql/graph/ir
import webql/lang/compiler/resolver/ast

/// Lowers a resolved operation parameter into an IR input.
pub fn lower(parameter: ast.Parameter) -> ir.Parameter {
  ir.Parameter(name: parameter.name, typename: parameter.typename.name)
}
