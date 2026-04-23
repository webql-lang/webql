import gleam/float
import gleam/int
import gleam/result
import gleam/string
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/cursor
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

const int = "Int"

const float = "Float"

const string = "String"

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
) -> Result(cursor.Cursor(ast.Primitive), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Int, span:), ..rest] -> {
      use value <- result.try(parse_int(source, span))
      Ok(cursor.Cursor(current: value, span:, rest:))
    }

    [token.Token(kind: token.Float, span:), ..rest] -> {
      use value <- result.try(parse_float(source, span))
      Ok(cursor.Cursor(current: value, span:, rest:))
    }

    [token.Token(kind: token.String, span:), ..rest] -> {
      let value = parse_string(source, span)

      Ok(cursor.Cursor(
        current: ast.String(name: string, value:, span:),
        span:,
        rest:,
      ))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_string(source: String, span: source.Span) {
  string.slice(
    from: source,
    at_index: span.start + 1,
    length: span.end - span.start - 2,
  )
}

fn parse_int(source: String, span: source.Span) {
  let literal = source.slice(source, span)

  case int.parse(literal) {
    Ok(value) -> Ok(ast.Int(name: int, value:, span:))

    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Int),
        span:,
      ))
  }
}

fn parse_float(source: String, span: source.Span) {
  let literal = source.slice(source, span)

  case float.parse(literal) {
    Ok(value) -> Ok(ast.Float(name: float, value:, span:))

    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(token.Float),
        span:,
      ))
  }
}
