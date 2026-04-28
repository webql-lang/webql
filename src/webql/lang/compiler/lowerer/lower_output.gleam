import webql/graph
import webql/lang/compiler/lowerer/lower_primitive
import webql/lang/compiler/resolver/ast

/// Lowers a resolved output into an IR output.
pub fn lower(output: ast.Output) -> graph.Output {
  case output {
    ast.PortOutput(path:, ..) -> graph.Output(path:)
    ast.PrimitiveOutput(value:, ..) ->
      graph.PrimitiveOutput(value: lower_primitive.lower(value))
  }
}
