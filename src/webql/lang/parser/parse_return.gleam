import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_typename
import webql/lang/source

/// Parses an operation return.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Return), diagnostic.Diagnostic) {
  use key <- result.try(parse_key(source, tokens))
  use rest <- result.try(parse_separator(key.rest))
  use cursor.Cursor(current: typename, span: typename_span, rest:) <- result.try(
    parse_typename.parse(source, rest),
  )

  let span = source.cover(key.span, typename_span)

  Ok(cursor.Cursor(
    current: ast.Return(span:, name: key.current, typename:),
    span:,
    rest:,
  ))
}

// PRIVATE FUNCTIONS
// =================
fn parse_key(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(String), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] ->
      Ok(cursor.Cursor(current: source.slice(source, span), span:, rest:))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_key(source, tokens)
    }
  }
}

fn parse_separator(
  tokens: List(token.Token),
) -> Result(List(token.Token), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Colon, ..), ..rest] -> Ok(rest)

    [token.Token(kind:, span:), ..] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(kind:),
        span:,
      ))

    [] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: 0, end: 0),
      ))
  }
}
