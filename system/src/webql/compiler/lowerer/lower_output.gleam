import webql/compiler/lowerer/lower_primitive
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved output into an IR output.
pub fn lower(output: hir.Output) -> graph.Output {
  case output {
    hir.PortOutput(path:, ..) -> graph.Output(path:)
    hir.PrimitiveOutput(value:, ..) ->
      graph.PrimitiveOutput(value: lower_primitive.lower(value))
  }
}
