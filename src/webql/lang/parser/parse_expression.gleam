import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_reference
import webql/lang/source

/// Parses an executable statement inside an operation body.
///
/// ## Examples
///
///     m = Math
///     1 -> m.l
///     m.out -> .out
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let identifier =
        ast.Parsed(node: source.slice(source, span), span:, tokens: rest)

      parse_lower_identifier_expression(source, identifier)
    }

    [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_edge_expression(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_lower_identifier_expression(
  source: String,
  identifier: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case identifier.tokens {
    [token.Token(kind: token.Equal, ..), ..tokens] ->
      parse_binding_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens:),
      )

    [token.Token(kind: token.Dot, ..), ..tokens] ->
      parse_node_port_edge_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens:),
      )

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, identifier.tokens))

      parse_lower_identifier_expression(
        source,
        ast.Parsed(node: identifier.node, span: identifier.span, tokens:),
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
      let name = source.slice(source, token.span)
      let span = source.cover(alias.span, token.span)

      Ok(ast.Parsed(
        node: ast.Binding(
          span:,
          name: alias.node,
          value: ast.Node(name:, span: token.span),
        ),
        span:,
        tokens:,
      ))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, alias.tokens))

      parse_binding_expression(
        source,
        ast.Parsed(node: alias.node, span: alias.span, tokens:),
      )
    }
  }
}

fn parse_node_port_edge_expression(
  source: String,
  alias: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case alias.tokens {
    [token.Token(kind: token.LowerIdentifier, ..) as tok, ..tokens] -> {
      let port = source.slice(source, tok.span)
      let span = source.cover(alias.span, tok.span)

      let from =
        ast.Parsed(
          node: ast.Access(path: [alias.node, port], span:),
          span:,
          tokens:,
        )

      parse_edge_expression_from(source, from)
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, alias.tokens))

      parse_node_port_edge_expression(
        source,
        ast.Parsed(node: alias.node, span: alias.span, tokens:),
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

      let span = source.cover(from.span, to.span)

      Ok(ast.Parsed(
        node: ast.Edge(span:, from: from.node, to: to.node),
        span:,
        tokens: to.tokens,
      ))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, from.tokens))

      parse_edge_expression_from(
        source,
        ast.Parsed(node: from.node, span: from.span, tokens:),
      )
    }
  }
}
