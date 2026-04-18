import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_primitive
import webql/lang/source

/// Parses a binding value.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Value), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] ->
      Ok(cursor.Cursor(
        current: ast.NodeValue(name: source.slice(source, span), span:),
        span:,
        rest:,
      ))

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_primitive_value(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_primitive_value(source: String, tokens: List(token.Token)) {
  use cursor.Cursor(current: value, span:, rest:) <- result.try(
    parse_primitive.parse(source, tokens),
  )

  Ok(cursor.Cursor(current: ast.PrimitiveValue(value:, span:), span:, rest:))
}
