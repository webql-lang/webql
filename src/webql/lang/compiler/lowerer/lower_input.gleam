import webql/graph
import webql/lang/compiler/resolver/ast

/// Lowers a resolved input path into an IR input.
pub fn lower(input: ast.Input) -> graph.Input {
  graph.Input(path: input.path)
}
