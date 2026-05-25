import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved input path into an IR input.
pub fn lower(input: hir.Input) -> graph.Input {
  graph.Input(path: input.path)
}
