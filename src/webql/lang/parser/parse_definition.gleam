import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source

/// Parses a nested operation definition.
pub fn parse(
  source: String,
  tokens: List(token.Token),
  parse_operation,
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] -> {
      let name =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_definition_name(source, name, parse_operation)
    }

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining, parse_operation)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_definition_name(
  source: String,
  name: cursor.Cursor(String),
  parse_operation,
) {
  use rest <- result.try(parse_equal(source, name.rest))
  use cursor.Cursor(current: operation, span:, rest:) <- result.try(
    parse_operation(source, rest),
  )

  let span = source.Span(start: name.span.start, end: span.end)

  Ok(cursor.Cursor(
    current: ast.Definition(name: name.current, operation:, span:),
    span:,
    rest:,
  ))
}

fn parse_equal(
  source: String,
  tokens: List(token.Token),
) -> Result(List(token.Token), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_equal(source, rest)
    }
  }
}
