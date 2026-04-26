import webql/compiler/ir
import webql/compiler/resolver/ast

/// Lowers a resolved primitive into an IR primitive.
pub fn lower(primitive: ast.Primitive) -> ir.Primitive {
  case primitive {
    ast.Int(value:, ..) -> ir.IntPrimitive(value:)
    ast.Float(value:, ..) -> ir.FloatPrimitive(value:)
    ast.String(value:, ..) -> ir.StringPrimitive(value:)
  }
}
