import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved value into an IR static value.
pub fn lower(value: hir.Value) -> graph.Value {
  case value {
    hir.Int(value:, ..) -> graph.Int(value:)
    hir.Float(value:, ..) -> graph.Float(value:)
    hir.String(value:, ..) -> graph.String(value:)
  }
}
