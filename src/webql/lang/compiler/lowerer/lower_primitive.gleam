import webql/graph
import webql/lang/compiler/hir

/// Lowers a resolved primitive into an IR primitive.
pub fn lower(primitive: hir.Primitive) -> graph.Primitive {
  case primitive {
    hir.Int(value:, ..) -> graph.IntPrimitive(value:)
    hir.Float(value:, ..) -> graph.FloatPrimitive(value:)
    hir.String(value:, ..) -> graph.StringPrimitive(value:)
  }
}
