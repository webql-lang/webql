import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_document
import webql/compiler/parser/parse_nonstarter

pub opaque type Parser {
  Parser(source: String, tokens: List(token.Token))
}

/// Creates a new parser instance from a source.
pub fn new(source: String, tokens: List(token.Token)) -> Parser {
  Parser(source:, tokens:)
}

/// Parses tokens into AST.
pub fn parse(parser: Parser) -> Result(ast.Document, diagnostic.Diagnostic) {
  use #(document, _span, rest) <- result.try(parse_document.parse(
    parser.source,
    parser.tokens,
  ))
  parse_eof(parser.source, rest, document)
}

// PRIVATE FUNCTIONS
// =================
fn parse_eof(
  source: String,
  tokens: List(token.Token),
  document: ast.Document,
) -> Result(ast.Document, diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.EOF, ..)] -> Ok(document)

    _token -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_eof(source, rest, document)
    }
  }
}
