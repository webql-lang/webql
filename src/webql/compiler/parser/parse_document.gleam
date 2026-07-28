import gleam/result
import webql/compiler/lexer
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
  tokens: List(lexer.Token),
) -> Result(
  #(ast.Document, source.Span, List(lexer.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.RArrow, ..), ..] ->
      parse_document(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_document(source: String, tokens: List(lexer.Token)) {
  use #(graph, span, rest) <- result.try(parse_graph.parse(source, tokens))

  Ok(#(ast.Document(graph:, span:), span, rest))
}
