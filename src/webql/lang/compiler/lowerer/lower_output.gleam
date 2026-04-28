import webql/lang/compiler/ir
import webql/lang/compiler/lowerer/lower_primitive
import webql/lang/compiler/resolver/ast

/// Lowers a resolved output into an IR output.
pub fn lower(output: ast.Output) -> ir.Output {
  case output {
    ast.PortOutput(path:, ..) -> ir.Output(path:)
    ast.PrimitiveOutput(value:, ..) ->
      ir.PrimitiveOutput(value: lower_primitive.lower(value))
  }
}
