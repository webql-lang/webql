import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_operation

/// Parses a module.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
///     -> out: Int { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Module), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.RArrow, ..), ..] -> parse_module(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_module(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Module), diagnostic.Diagnostic) {
  use operation <- result.try(parse_operation.parse(source, tokens))

  Ok(cursor.Cursor(
    current: ast.Module(operation: operation.current, span: operation.span),
    span: operation.span,
    rest: operation.rest,
  ))
}
