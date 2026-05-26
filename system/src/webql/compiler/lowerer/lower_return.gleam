import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved operation return into an IR output.
pub fn lower(return: hir.Return) -> graph.Return {
  graph.Return(name: return.name, port: return.typename.name)
}
