import webql/compiler/parser
import webql/compiler/resolver/hir

/// Resolves a parser value into a resolver value.
pub fn resolve(value: parser.Value) -> hir.Value {
  case value {
    parser.Int(name:, value:, span:) -> hir.Int(name:, value:, span:)
    parser.Float(name:, value:, span:) -> hir.Float(name:, value:, span:)
    parser.String(name:, value:, span:) -> hir.String(name:, value:, span:)
  }
}
