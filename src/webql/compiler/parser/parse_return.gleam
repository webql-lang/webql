import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/cursor
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_typename
import webql/compiler/source

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
fn parse_key(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] ->
      Ok(cursor.Cursor(current: source.slice(source, span), span:, rest:))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_key(source, tokens)
    }
  }
}

fn parse_separator(tokens: List(token.Token)) {
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
