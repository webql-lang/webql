import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_typename
import webql/lang/source

/// Parses a parameter or single key/value (type) pair.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Parameter), diagnostic.Diagnostic) {
  use key <- result.try(parse_key(source, tokens))
  use tokens <- result.try(parse_separator(key.tokens))
  use ast.Parsed(node: typename, span: typename_span, tokens:) <- result.try(
    parse_typename.parse(source, tokens),
  )

  let span = source.cover(key.span, typename_span)

  Ok(ast.Parsed(
    node: ast.Parameter(span:, name: key.node, typename:),
    span:,
    tokens:,
  ))
}

// PRIVATE FUNCTIONS
// =================
fn parse_key(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(String), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] ->
      Ok(ast.Parsed(node: source.slice(source, span), span:, tokens: rest))

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
