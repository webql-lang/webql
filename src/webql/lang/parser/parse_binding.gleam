import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source

/// Parses a binding inside an operation body.
///
/// ## Examples
///
///     m = Math
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Binding), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_binding_equal(source, name)
    }

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_binding_equal(
  source: String,
  name: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Binding), diagnostic.Diagnostic) {
  let cursor.Cursor(rest:, span:, current:) = name

  case rest {
    [token.Token(kind: token.Equal, ..), ..rest] ->
      parse_binding_value(source, cursor.Cursor(current:, span:, rest:))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, rest))
      parse_binding_equal(source, cursor.Cursor(current:, span:, rest:))
    }
  }
}

fn parse_binding_value(
  source: String,
  binding: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Binding), diagnostic.Diagnostic) {
  let cursor.Cursor(rest:, span:, current:) = binding
  case rest {
    [token.Token(kind: token.UpperIdentifier, ..) as token, ..rest] -> {
      let name = source.slice(source, token.span)
      let span = source.cover(span, token.span)

      Ok(cursor.Cursor(
        current: ast.Binding(
          span:,
          name: current,
          value: ast.Node(name:, span: token.span),
        ),
        span:,
        rest:,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, rest))
      parse_binding_value(source, cursor.Cursor(current:, span:, rest:))
    }
  }
}
