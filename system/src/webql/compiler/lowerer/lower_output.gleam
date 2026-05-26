import webql/compiler/lowerer/lower_primitive
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved output into an IR source.
pub fn lower(output: hir.Output) -> graph.Source {
  case output {
    hir.PortOutput(path:, ..) -> graph.Output(path:)
    hir.PrimitiveOutput(value:, ..) ->
      graph.Static(value: lower_primitive.lower(value))
  }
}
