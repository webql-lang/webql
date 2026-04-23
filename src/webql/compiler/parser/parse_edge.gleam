import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_input
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_output
import webql/compiler/source

/// Parses an edge inside an operation body.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Edge, source.Span, List(token.Token)), diagnostic.Diagnostic) {
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

fn parse_arrow(
  source: String,
  from: #(ast.Output, source.Span, List(token.Token)),
) {
  let #(from, from_span, rest) = from

  case rest {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use to <- result.try(parse_input.parse(source, rest))
      let #(to, to_span, rest) = to
      let span = source.cover(from_span, to_span)

      Ok(#(ast.Edge(span:, from:, to:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, rest))
      parse_arrow(source, #(from, from_span, rest))
    }
  }
}
