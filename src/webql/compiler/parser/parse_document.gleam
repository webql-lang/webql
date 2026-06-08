import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_graph
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses a document.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
///     -> out: Int { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Document, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.RArrow, ..), ..] ->
      parse_document(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_document(source: String, tokens: List(token.Token)) {
  use #(graph, span, rest) <- result.try(parse_graph.parse(source, tokens))

  Ok(#(ast.Document(graph:, span:), span, rest))
}
