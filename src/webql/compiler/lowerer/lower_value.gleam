import webql/compiler/resolver
import webql/graph

/// Lowers a resolved value into an IR literal value.
pub fn lower(value: resolver.Value) -> graph.Value {
  case value {
    resolver.Int(value:, ..) -> graph.Int(value:)
    resolver.Float(value:, ..) -> graph.Float(value:)
    resolver.String(value:, ..) -> graph.String(value:)
  }
}
