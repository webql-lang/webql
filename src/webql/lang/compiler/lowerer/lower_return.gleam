import webql/graph
import webql/lang/compiler/hir

/// Lowers a resolved operation return into an IR output.
pub fn lower(return: hir.Return) -> graph.Return {
  graph.Return(name: return.name, typename: return.typename.name)
}
