import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_annotation
import webql/lang/parser/parse_nonstarter
import webql/lang/source
import webql/lang/source/position

/// Parses a field or single key/value (type) pair.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Field), diagnostic.Diagnostic) {
  use key <- result.try(parse_key(source, tokens))
  use tokens <- result.try(parse_separator(source, key.tokens))
  use ast.Parsed(node: annotation, span: annotation_span, tokens: tokens) <- result.try(
    parse_annotation.parse(source, tokens),
  )

  let span = position.cover(key.span, annotation_span)

  Ok(ast.Parsed(
    node: ast.Field(span: span, name: key.node, annotation: annotation),
    span: span,
    tokens: tokens,
  ))
}

fn parse_key(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(String), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] ->
      Ok(ast.Parsed(node: source.slice(source, span), span: span, tokens: rest))

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_key(source, tokens)
    }
  }
}

fn parse_separator(
  source: String,
  tokens: List(token.Token),
) -> Result(List(token.Token), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Colon, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_separator(source, tokens)
    }
  }
}
