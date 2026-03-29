import gleam/float
import gleam/int
import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source/position

/// Parses a literal value.
///
/// ## Examples
///
///     1
///     1.23
///     "test"
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Value, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Int, span: span), ..rest] -> {
      let value =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      use value <- result.try(parse_int(value, span))
      Ok(#(value, rest))
    }

    [token.Token(kind: token.Float, span: span), ..rest] -> {
      let value =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      use value <- result.try(parse_float(value, span))
      Ok(#(value, rest))
    }

    [token.Token(kind: token.String, span: span), ..rest] -> {
      let length = span.end - span.start
      let quotes = 2

      let value =
        string.slice(
          from: source,
          at_index: span.start + 1,
          length: length - quotes,
        )

      Ok(#(ast.StringValue(value:), rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_int(value: String, span: position.Span) {
  case int.parse(value) {
    Ok(value) -> Ok(ast.IntValue(value: value))
    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Int),
        span:,
      ))
  }
}

fn parse_float(value: String, span: position.Span) {
  case float.parse(value) {
    Ok(value) -> Ok(ast.FloatValue(value: value))
    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Float),
        span:,
      ))
  }
}
