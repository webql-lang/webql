import webql/graph
import webql/lang/compiler/hir

/// Lowers a resolved operation parameter into an IR input.
pub fn lower(parameter: hir.Parameter) -> graph.Parameter {
  graph.Parameter(name: parameter.name, typename: parameter.typename.name)
}
