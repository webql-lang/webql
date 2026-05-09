import webql/graph
import webql/lang/compiler/hir

/// Lowers a resolved input path into an IR input.
pub fn lower(input: hir.Input) -> graph.Input {
  graph.Input(path: input.path)
}
