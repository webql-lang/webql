import webql/lang/compiler/parser/ast as parser_ast
import webql/lang/compiler/resolver/ast

/// Resolves a parser primitive into a resolver primitive.
pub fn resolve(value: parser_ast.Primitive) -> ast.Primitive {
  case value {
    parser_ast.Int(name:, value:, span:) -> ast.Int(name:, value:, span:)
    parser_ast.Float(name:, value:, span:) -> ast.Float(name:, value:, span:)
    parser_ast.String(name:, value:, span:) -> ast.String(name:, value:, span:)
  }
}
