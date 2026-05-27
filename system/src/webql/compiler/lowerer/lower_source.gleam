import webql/compiler/lowerer/lower_value
import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved source into an IR source.
pub fn lower(source: hir.Source) -> graph.Source {
  case source {
    hir.Output(path:, ..) -> graph.Output(path:)
    hir.Static(value:, ..) -> graph.Static(value: lower_value.lower(value))
  }
}
