import gleam/float
import gleam/int
import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source

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
) -> Result(ast.Parsed(ast.Value), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Int, span:), ..rest] -> {
      let literal = source.slice(source, span)
      use value <- result.try(parse_int(literal, span))

      Ok(ast.Parsed(node: value, span:, tokens: rest))
    }

    [token.Token(kind: token.Float, span:), ..rest] -> {
      let literal = source.slice(source, span)
      use value <- result.try(parse_float(literal, span))

      Ok(ast.Parsed(node: value, span:, tokens: rest))
    }

    [token.Token(kind: token.String, span:), ..rest] -> {
      let value =
        string.slice(
          from: source,
          at_index: span.start + 1,
          length: span.end - span.start - 2,
        )

      Ok(ast.Parsed(node: ast.StringValue(value:, span:), span:, tokens: rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_int(
  raw: String,
  span: source.Span,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case int.parse(raw) {
    Ok(value) -> Ok(ast.IntValue(value:, span:))

    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Int),
        span:,
      ))
  }
}

fn parse_float(
  raw: String,
  span: source.Span,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case float.parse(raw) {
    Ok(value) -> Ok(ast.FloatValue(value:, span:))

    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Float),
        span:,
      ))
  }
}
