import webql/graph
import webql/lang/compiler/resolver/ast

/// Lowers a resolved primitive into an IR primitive.
pub fn lower(primitive: ast.Primitive) -> graph.Primitive {
  case primitive {
    ast.Int(value:, ..) -> graph.IntPrimitive(value:)
    ast.Float(value:, ..) -> graph.FloatPrimitive(value:)
    ast.String(value:, ..) -> graph.StringPrimitive(value:)
  }
}
