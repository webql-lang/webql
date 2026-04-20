import webql/compiler/parser/ast as parser_ast

const int = "Int"

const float = "Float"

const string = "String"

/// Grabs a typename for a given primitive.
pub fn get_typename(value: parser_ast.Primitive) {
  case value {
    parser_ast.Int(..) -> int
    parser_ast.Float(..) -> float
    parser_ast.String(..) -> string
  }
}
