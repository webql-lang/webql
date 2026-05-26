import webql/compiler/resolver/hir
import webql/graph

/// Lowers a resolved primitive into an IR static value.
pub fn lower(primitive: hir.Primitive) -> graph.Value {
  case primitive {
    hir.Int(value:, ..) -> graph.Int(value:)
    hir.Float(value:, ..) -> graph.Float(value:)
    hir.String(value:, ..) -> graph.String(value:)
  }
}
