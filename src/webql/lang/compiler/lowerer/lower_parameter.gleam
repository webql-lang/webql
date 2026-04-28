import webql/graph
import webql/lang/compiler/resolver/ast

/// Lowers a resolved operation parameter into an IR input.
pub fn lower(parameter: ast.Parameter) -> graph.Parameter {
  graph.Parameter(name: parameter.name, typename: parameter.typename.name)
}
