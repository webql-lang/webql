import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast

/// Resolves a parser primitive into a resolver primitive.
pub fn resolve(value: parser_ast.Primitive) -> ast.Primitive {
  case value {
    parser_ast.Int(value:, span:) -> ast.Int(value:, span:)
    parser_ast.Float(value:, span:) -> ast.Float(value:, span:)
    parser_ast.String(value:, span:) -> ast.String(value:, span:)
  }
}
