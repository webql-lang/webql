import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast

/// Resolves a parser primitive into a resolver primitive.
pub fn resolve(value: ast.Primitive) -> hir.Primitive {
  case value {
    ast.Int(name:, value:, span:) -> hir.Int(name:, value:, span:)
    ast.Float(name:, value:, span:) -> hir.Float(name:, value:, span:)
    ast.String(name:, value:, span:) -> hir.String(name:, value:, span:)
  }
}
