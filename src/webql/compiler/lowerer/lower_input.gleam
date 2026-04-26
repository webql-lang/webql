import webql/compiler/ir
import webql/compiler/resolver/ast

/// Lowers a resolved input path into an IR input.
pub fn lower(input: ast.Input) -> ir.Input {
  ir.Input(path: input.path)
}
