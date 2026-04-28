import webql/graph
import webql/lang/compiler/resolver/ast

/// Lowers a resolved operation return into an IR output.
pub fn lower(return: ast.Return) -> graph.Return {
  graph.Return(name: return.name, typename: return.typename.name)
}
