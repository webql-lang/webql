import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_source
import webql/compiler/parser/parse_target
import webql/compiler/source

/// Parses an edge inside a graph body.
pub fn parse(
  document: String,
  tokens: List(token.Token),
) -> Result(#(ast.Edge, source.Span, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_edge_source(document, tokens)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(document, tokens))
      parse(document, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_edge_source(document: String, tokens: List(token.Token)) {
  use source <- result.try(parse_source.parse(document, tokens))
  parse_arrow(document, source)
}

fn parse_arrow(
  document: String,
  source: #(ast.Source, source.Span, List(token.Token)),
) {
  let #(source, source_span, rest) = source

  case rest {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use target <- result.try(parse_target.parse(document, rest))
      let #(target, target_span, rest) = target
      let span = source.cover(source_span, target_span)

      Ok(#(ast.Edge(span:, source:, target:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(document, rest))
      parse_arrow(document, #(source, source_span, rest))
    }
  }
}
