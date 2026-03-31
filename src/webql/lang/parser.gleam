import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_operation

pub opaque type Parser {
  Parser(source: String, tokens: List(token.Token))
}

/// Creates a new parser instance from a source.
pub fn new(source: String, tokens: List(token.Token)) -> Parser {
  Parser(source:, tokens:)
}

/// Parses tokens into AST.
pub fn parse(parser: Parser) -> Result(ast.Operation, diagnostic.Diagnostic) {
  use operation <- result.try(parse_operation.parse(
    parser.source,
    parser.tokens,
  ))

  parse_eof(parser.source, operation.tokens, operation.node)
}

fn parse_eof(
  source: String,
  tokens: List(token.Token),
  operation: ast.Operation,
) -> Result(ast.Operation, diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.EOF, ..)] -> Ok(operation)

    _token -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_eof(source, rest, operation)
    }
  }
}
