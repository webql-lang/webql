import gleam/bit_array
import webql/compiler/lexer
import webql/compiler/parser/diagnostic
import webql/compiler/source

/// Handles non-starter tokens (ie. spaces and comments) that have no material effect on parsing.
/// If the remaining tokens still are invalid, returns an unexpected token or EOF diagnostic.
pub fn parse(
  source source: String,
  tokens tokens: List(lexer.Token),
) -> Result(List(lexer.Token), diagnostic.Diagnostic) {
  let bytes = bit_array.from_string(source)
  let byte_length = bit_array.byte_size(bytes)

  case tokens {
    [lexer.Token(kind: lexer.Whitespace, ..), ..rest]
    | [lexer.Token(kind: lexer.Comment, ..), ..rest] ->
      Ok(parse_nonstarter(rest))

    [lexer.Token(kind: lexer.EOF, ..), ..] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: byte_length, end: byte_length),
      ))

    [token, ..] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.kind),
        span: token.span,
      ))

    [] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: byte_length, end: byte_length),
      ))
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_nonstarter(tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.Whitespace, ..), ..rest]
    | [lexer.Token(kind: lexer.Comment, ..), ..rest] -> parse_nonstarter(rest)

    _token -> tokens
  }
}
