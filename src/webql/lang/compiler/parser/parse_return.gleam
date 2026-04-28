import gleam/result
import webql/lang/compiler/lexer/token
import webql/lang/compiler/parser/ast
import webql/lang/compiler/parser/diagnostic
import webql/lang/compiler/parser/parse_nonstarter
import webql/lang/compiler/parser/parse_typename
import webql/lang/compiler/source

/// Parses an operation return.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Return, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  use key <- result.try(parse_key(source, tokens))
  let #(name, key_span, rest) = key
  use rest <- result.try(parse_separator(rest))
  use #(typename, typename_span, rest) <- result.try(parse_typename.parse(
    source,
    rest,
  ))

  let span = source.cover(key_span, typename_span)

  Ok(#(ast.Return(span:, name:, typename:), span, rest))
}

// PRIVATE FUNCTIONS
// =================
fn parse_key(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] ->
      Ok(#(source.slice(source, span), span, rest))

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
