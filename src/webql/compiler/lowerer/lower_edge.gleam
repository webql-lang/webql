import webql/compiler/ir
import webql/compiler/lowerer/lower_input
import webql/compiler/lowerer/lower_output
import webql/compiler/resolver/ast

/// Lowers a resolved edge into an IR edge.
pub fn lower(edge: ast.Edge) -> ir.Edge {
  ir.Edge(from: lower_output.lower(edge.from), to: lower_input.lower(edge.to))
}
