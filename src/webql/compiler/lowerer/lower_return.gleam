import webql/compiler/resolver
import webql/graph

/// Lowers a resolved graph return into an IR output.
pub fn lower(return: resolver.Return) -> graph.Return {
  graph.Return(name: return.name, port: return.port.name)
}
