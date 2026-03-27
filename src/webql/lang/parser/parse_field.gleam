import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_annotation
import webql/lang/parser/parse_nonstarter

/// Parses a fields or single key/value (type) pairs.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Field, List(token.Token)), diagnostic.Diagnostic) {
  use #(key, tokens) <- result.try(parse_key(source, tokens))
  use tokens <- result.try(parse_seperator(source, tokens))
  use #(annotation, tokens) <- result.try(parse_annotation.parse(source, tokens))

  Ok(#(ast.Field(name: key, annotation: annotation), tokens))
}

fn parse_key(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let name =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      Ok(#(name, rest))
    }

    _token -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_key(source, tokens)
    }
  }
}

fn parse_seperator(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.Colon, ..), ..rest] -> Ok(rest)
    _token -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_seperator(source, tokens)
    }
  }
}
