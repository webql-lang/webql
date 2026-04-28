import webql/graph
import webql/lang/compiler/lowerer/lower_input
import webql/lang/compiler/lowerer/lower_output
import webql/lang/compiler/resolver/ast

/// Lowers a resolved edge into an IR edge.
pub fn lower(edge: ast.Edge) -> graph.Edge {
  graph.Edge(
    from: lower_output.lower(edge.from),
    to: lower_input.lower(edge.to),
  )
}
