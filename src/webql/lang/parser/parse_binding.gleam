import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_value
import webql/lang/source

/// Parses a binding inside an operation body.
///
/// ## Examples
///
///     m = Math
///     value = "hello world"
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Binding), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)
      parse_binding_name(source, name)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_binding_name(source: String, name: cursor.Cursor(String)) {
  use rest <- result.try(parse_equal(source, name.rest))
  use cursor.Cursor(current: value, span:, rest:) <- result.try(
    parse_value.parse(source, rest),
  )

  let span = source.cover(name.span, span)

  Ok(cursor.Cursor(
    current: ast.Binding(name: name.current, value:, span:),
    span:,
    rest:,
  ))
}

fn parse_equal(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_equal(source, rest)
    }
  }
}
