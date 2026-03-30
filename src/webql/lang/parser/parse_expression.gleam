import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_reference
import webql/lang/source
import webql/lang/source/position

pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let identifier =
        ast.Parsed(node: source.slice(source, span), span: span, tokens: rest)

      parse_lower_identifier_expression(source, identifier)
    }

    [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_edge_expression(source, tokens)

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_lower_identifier_expression(
  source: String,
  identifier: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case identifier.tokens {
    [token.Token(kind: token.Equal, ..), ..tokens] ->
      parse_binding_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens: tokens),
      )

    [token.Token(kind: token.Dot, ..), ..tokens] ->
      parse_node_port_edge_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens: tokens),
      )

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, identifier.tokens))

      parse_lower_identifier_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens: tokens),
      )
    }
  }
}

fn parse_binding_expression(
  source: String,
  alias: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case alias.tokens {
    [token.Token(kind: token.UpperIdentifier, ..) as token, ..tokens] -> {
      let node = source.slice(source, token.span)
      let span = position.cover(alias.span, token.span)

      Ok(ast.Parsed(
        node: ast.BindingExpression(span: span, alias: alias.node, node: node),
        span: span,
        tokens: tokens,
      ))
    }

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, alias.tokens))

      parse_binding_expression(
        source,
        ast.Parsed(node: alias.node, span: alias.span, tokens: tokens),
      )
    }
  }
}

fn parse_node_port_edge_expression(
  source: String,
  alias: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case alias.tokens {
    [token.Token(kind: token.LowerIdentifier, ..) as token, ..tokens] -> {
      let port = source.slice(source, token.span)
      let span = position.cover(alias.span, token.span)

      let from =
        ast.Parsed(
          node: ast.NodePortReference(span: span, alias: alias.node, port: port),
          span: span,
          tokens: tokens,
        )

      parse_edge_expression_from(source, from)
    }

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, alias.tokens))

      parse_node_port_edge_expression(
        source,
        ast.Parsed(node: alias.node, span: alias.span, tokens: tokens),
      )
    }
  }
}

fn parse_edge_expression(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  use from <- result.try(parse_reference.parse(source, tokens))
  parse_edge_expression_from(source, from)
}

fn parse_edge_expression_from(
  source: String,
  from: ast.Parsed(ast.Reference),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case from.tokens {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use to <- result.try(parse_reference.parse(source, rest))

      let span = position.cover(from.span, to.span)

      Ok(ast.Parsed(
        node: ast.EdgeExpression(span: span, from: from.node, to: to.node),
        span: span,
        tokens: to.tokens,
        // ✅ FIX: use RHS remainder ONLY
      ))
    }

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, from.tokens))

      parse_edge_expression_from(
        source,
        ast.Parsed(node: from.node, span: from.span, tokens: tokens),
      )
    }
  }
}
