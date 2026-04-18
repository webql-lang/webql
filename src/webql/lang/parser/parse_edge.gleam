import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_input
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_output
import webql/lang/source

/// Parses an edge inside an operation body.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Edge), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_edge_from(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_edge_from(source: String, tokens: List(token.Token)) {
  use from <- result.try(parse_output.parse(source, tokens))
  parse_arrow(source, from)
}

fn parse_arrow(source: String, from: cursor.Cursor(ast.Output)) {
  case from.rest {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use to <- result.try(parse_input.parse(source, rest))
      let span = source.cover(from.span, to.span)

      Ok(cursor.Cursor(
        current: ast.Edge(span:, from: from.current, to: to.current),
        span:,
        rest: to.rest,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, from.rest))
      parse_arrow(
        source,
        cursor.Cursor(current: from.current, span: from.span, rest:),
      )
    }
  }
}
