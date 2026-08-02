import webql/compiler/lowerer/lower_value
import webql/compiler/resolver
import webql/graph

/// Lowers a resolved source into an IR source.
pub fn lower(source: resolver.Source) -> graph.Source {
  case source {
    resolver.Output(path:, ..) -> graph.Output(path:)
    resolver.Literal(value:, ..) ->
      graph.Literal(value: lower_value.lower(value))
  }
}
