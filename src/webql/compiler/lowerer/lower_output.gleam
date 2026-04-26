import webql/compiler/ir
import webql/compiler/lowerer/lower_primitive
import webql/compiler/resolver/ast

/// Lowers a resolved output into an IR output.
pub fn lower(output: ast.Output) -> ir.Output {
  case output {
    ast.PortOutput(path:, ..) -> ir.Output(path:)
    ast.PrimitiveOutput(value:, ..) ->
      ir.PrimitiveOutput(value: lower_primitive.lower(value))
  }
}
