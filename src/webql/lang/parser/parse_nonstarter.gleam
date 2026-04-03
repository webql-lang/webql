import gleam/bit_array
import webql/lang/lexer/token
import webql/lang/parser/diagnostic
import webql/lang/source

/// Handles non-starter tokens (ie. spaces) that have no material effect on parsing.
/// If the remaining tokens still are invalid, returns an unexpected token or EOF diagnostic.
pub fn parse(
  source source: String,
  tokens tokens: List(token.Token),
) -> Result(List(token.Token), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Space, ..), ..rest] -> Ok(parse_space(rest))
    [token.Token(kind: token.EOF, ..), ..] -> unexpected_eof(source)

    [token, ..] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.kind),
        span: token.span,
      ))

    [] -> unexpected_eof(source)
  }
}

// PRIVATE FUNCTIONS
// =================
fn unexpected_eof(source: String) {
  let bytes = bit_array.from_string(source)
  let byte_length = bit_array.byte_size(bytes)

  Error(diagnostic.Diagnostic(
    kind: diagnostic.UnexpectedEof,
    span: source.Span(start: byte_length, end: byte_length),
  ))
}

fn parse_space(tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.Space, ..), ..rest] -> parse_space(rest)
    _token -> tokens
  }
}
