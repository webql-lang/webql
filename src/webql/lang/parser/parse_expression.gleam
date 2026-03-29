import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_reference

/// Parse executable statements in an operation body.
///
/// ## Examples
///
///     m = Math
///     1 -> m.l
///     m.out -> .out
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let value =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      parse_lower_identifier_expression(source, rest, value)
    }

    [token.Token(kind: token.Dot, ..), ..] ->
      parse_edge_expression(source, tokens)

    [token.Token(kind: token.Int, ..), ..] ->
      parse_edge_expression(source, tokens)

    [token.Token(kind: token.Float, ..), ..] ->
      parse_edge_expression(source, tokens)

    [token.Token(kind: token.String, ..), ..] ->
      parse_edge_expression(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_lower_identifier_expression(
  source: String,
  tokens: List(token.Token),
  value: String,
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Equal, ..), ..rest] ->
      parse_binding_expression(source, rest, value)

    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_edge_expression(source, rest, value)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_lower_identifier_expression(source, tokens, value)
    }
  }
}

fn parse_binding_expression(
  source: String,
  tokens: List(token.Token),
  alias: String,
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span: span), ..rest] -> {
      let node =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      Ok(#(ast.BindingExpression(alias:, node:), rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_binding_expression(source, tokens, alias)
    }
  }
}

fn parse_node_port_edge_expression(
  source: String,
  tokens: List(token.Token),
  alias: String,
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let port =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      let from = ast.NodePortReference(alias:, port:)
      parse_edge_expression_from(source, rest, from)
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_node_port_edge_expression(source, tokens, alias)
    }
  }
}

fn parse_edge_expression(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  use #(from, tokens) <- result.try(parse_reference.parse(source, tokens))
  parse_edge_expression_from(source, tokens, from)
}

fn parse_edge_expression_from(
  source: String,
  tokens: List(token.Token),
  from: ast.Reference,
) -> Result(#(ast.Expression, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use #(to, rest) <- result.try(parse_reference.parse(source, rest))
      Ok(#(ast.EdgeExpression(from:, to:), rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_edge_expression_from(source, tokens, from)
    }
  }
}
