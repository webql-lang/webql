import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_port
import webql/compiler/source

/// Parses a graph parameter.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Parameter, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  use key <- result.try(parse_key(source, tokens))
  let #(name, key_span, rest) = key
  use rest <- result.try(parse_separator(rest))
  use #(port, span, rest) <- result.try(parse_port.parse(source, rest))

  let span = source.cover(key_span, span)

  Ok(#(ast.Parameter(span:, name:, port:), span, rest))
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
