import gleam/result
import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses a nested graph supernode.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
  parse_graph: fn(String, List(lexer.Token)) ->
    Result(#(ast.Graph, source.Span, List(lexer.Token)), diagnostic.Diagnostic),
) -> Result(#(ast.Node, source.Span, List(lexer.Token)), diagnostic.Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.UpperIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)

      parse_supernode_name(source, name, parse_graph)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest, parse_graph)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_supernode_name(
  source: String,
  name: #(String, source.Span, List(lexer.Token)),
  parse_graph: fn(String, List(lexer.Token)) ->
    Result(#(ast.Graph, source.Span, List(lexer.Token)), diagnostic.Diagnostic),
) {
  let #(name, name_span, rest) = name
  use rest <- result.try(parse_equal(source, rest))
  use #(graph, graph_span, rest) <- result.try(parse_graph(source, rest))

  let span = source.Span(start: name_span.start, end: graph_span.end)

  Ok(#(ast.Supernode(name:, graph:, span:), span, rest))
}

fn parse_equal(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.Equal, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_equal(source, rest)
    }
  }
}
