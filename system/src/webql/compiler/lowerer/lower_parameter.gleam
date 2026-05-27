import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved graph parameter into an IR input.
pub fn lower(parameter: hir.Parameter) -> graph.Parameter {
  graph.Parameter(name: parameter.name, port: parameter.port.name)
}
