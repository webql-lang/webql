import webql/compiler/resolver
import webql/graph

/// Lowers a resolved graph parameter into an IR input.
pub fn lower(parameter: resolver.Parameter) -> graph.Parameter {
  graph.Parameter(name: parameter.name, port: parameter.port.name)
}
