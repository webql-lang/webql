import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses a node inside a graph body.
///
/// ## Examples
///
///     m = Math
///     value = "hello world"
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Node, source.Span, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let name_span = span

      use rest <- result.try(parse_equal(source, rest))
      use #(node, node_span, rest) <- result.try(parse_node(source, rest))

      let span = source.cover(name_span, node_span)

      Ok(#(ast.Node(name:, node:, span:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] ->
      Ok(#(source.slice(source, span), span, rest))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_node(source, tokens)
    }
  }
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
