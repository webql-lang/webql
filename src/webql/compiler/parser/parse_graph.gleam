import gleam/list
import gleam/result
import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_edge
import webql/compiler/parser/parse_node
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_parameter
import webql/compiler/parser/parse_return
import webql/compiler/parser/parse_supernode
import webql/compiler/source

/// Parses a graph.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(ast.Graph, source.Span, List(lexer.Token)), diagnostic.Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..]
    | [lexer.Token(kind: lexer.Dot, span:), ..]
    | [lexer.Token(kind: lexer.RArrow, span:), ..] ->
      parse_graph(source, tokens, span.start)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_graph(source: String, tokens: List(lexer.Token), start: Int) {
  use #(parameters, _span, rest) <- result.try(
    parse_parameters(source, tokens, []),
  )

  use #(returns, _span, rest) <- result.try(parse_returns(source, rest, []))

  use #(#(nodes, edges), span, rest) <- result.try(
    parse_body(source, rest, [], []),
  )

  let span = source.Span(start: start, end: span.end)

  Ok(#(
    ast.Graph(
      parameters: list.reverse(parameters),
      returns: list.reverse(returns),
      nodes: list.reverse(nodes),
      edges: list.reverse(edges),
      span:,
    ),
    span,
    rest,
  ))
}

fn parse_parameters(
  source: String,
  tokens: List(lexer.Token),
  parameters: List(ast.Parameter),
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] -> {
      use #(parameter, _span, rest) <- result.try(parse_parameter.parse(
        source,
        tokens,
      ))

      parse_parameters(source, rest, [parameter, ..parameters])
    }

    [lexer.Token(kind: lexer.Comma, ..), ..rest] ->
      parse_parameters(source, rest, parameters)

    [lexer.Token(kind: lexer.RArrow, span:), ..rest] ->
      Ok(#(parameters, span, rest))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_parameters(source, rest, parameters)
    }
  }
}

fn parse_returns(
  source: String,
  tokens: List(lexer.Token),
  returns: List(ast.Return),
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] -> {
      use #(return, _span, rest) <- result.try(parse_return.parse(
        source,
        tokens,
      ))

      parse_returns(source, rest, [return, ..returns])
    }

    [lexer.Token(kind: lexer.Comma, ..), ..rest] ->
      parse_returns(source, rest, returns)

    [lexer.Token(kind: lexer.LBrace, span:), ..] -> Ok(#(returns, span, tokens))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_returns(source, rest, returns)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(ast.Node),
  edges: List(ast.Edge),
) -> Result(
  #(#(List(ast.Node), List(ast.Edge)), source.Span, List(lexer.Token)),
  diagnostic.Diagnostic,
) {
  use tokens <- result.try(parse_left_brace(source, tokens))
  parse_block_body(source, tokens, nodes, edges)
}

fn parse_left_brace(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.LBrace, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_left_brace(source, rest)
    }
  }
}

fn parse_block_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(ast.Node),
  edges: List(ast.Edge),
) {
  case tokens {
    [lexer.Token(kind: lexer.RBrace, span:), ..rest] ->
      Ok(#(#(nodes, edges), span, rest))

    [lexer.Token(kind: lexer.UpperIdentifier, ..), ..] -> {
      use #(node, _span, rest) <- result.try(parse_supernode.parse(
        source,
        tokens,
        parse,
      ))

      parse_block_body(source, rest, [node, ..nodes], edges)
    }

    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] ->
      parse_lower_block_body(source, tokens, nodes, edges)

    [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> {
      use #(edge, _span, rest) <- result.try(parse_edge.parse(source, tokens))

      parse_block_body(source, rest, nodes, [edge, ..edges])
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_block_body(source, rest, nodes, edges)
    }
  }
}

fn parse_lower_block_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(ast.Node),
  edges: List(ast.Edge),
) {
  case tokens {
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..),
      lexer.Token(kind: lexer.Equal, ..),
      ..
    ] -> {
      use #(node, _span, rest) <- result.try(parse_node.parse(source, tokens))

      parse_block_body(source, rest, [node, ..nodes], edges)
    }

    [
      lexer.Token(kind: lexer.LowerIdentifier, ..),
      lexer.Token(kind: lexer.Dot, ..),
      ..
    ] -> {
      use #(edge, _span, rest) <- result.try(parse_edge.parse(source, tokens))
      parse_block_body(source, rest, nodes, [edge, ..edges])
    }

    [lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier, ..rest] -> {
      use rest <- result.try(parse_nonstarter.parse(source, rest))

      parse_lower_block_body(source, [identifier, ..rest], nodes, edges)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_block_body(source, rest, nodes, edges)
    }
  }
}
