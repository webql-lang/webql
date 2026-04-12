import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
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
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let identifier =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_lower_identifier_definition(source, identifier)
    }

    [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_edge_definition(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_lower_identifier_definition(
  source: String,
  identifier: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case identifier.rest {
    [token.Token(kind: token.Equal, ..), ..rest] ->
      parse_binding_definition(
        source,
        cursor.Cursor(current: identifier.current, span: identifier.span, rest:),
      )

    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_edge_definition(
        source,
        cursor.Cursor(current: identifier.current, span: identifier.span, rest:),
      )

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, identifier.rest))

      parse_lower_identifier_definition(
        source,
        cursor.Cursor(current: identifier.current, span: identifier.span, rest:),
      )
    }
  }
}

fn parse_binding_definition(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.UpperIdentifier, ..) as tok, ..rest] -> {
      let name = source.slice(source, tok.span)
      let span = source.cover(alias.span, tok.span)

      Ok(cursor.Cursor(
        current: ast.Binding(
          span:,
          name: alias.current,
          value: ast.Node(name:, span: tok.span),
        ),
        span:,
        rest:,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, alias.rest))

      parse_binding_definition(
        source,
        cursor.Cursor(current: alias.current, span: alias.span, rest:),
      )
    }
  }
}

fn parse_node_port_edge_definition(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.LowerIdentifier, ..) as tok, ..rest] -> {
      let port = source.slice(source, tok.span)
      let span = source.cover(alias.span, tok.span)

      let from =
        cursor.Cursor(
          current: ast.Access(path: [alias.current, port], span:),
          span:,
          rest:,
        )

      parse_edge_definition_from(source, from)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, alias.rest))

      parse_node_port_edge_definition(
        source,
        cursor.Cursor(current: alias.current, span: alias.span, rest:),
      )
    }
  }
}

fn parse_edge_definition(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  use from <- result.try(parse_reference.parse(source, tokens))
  parse_edge_definition_from(source, from)
}

fn parse_edge_definition_from(
  source: String,
  from: cursor.Cursor(ast.Reference),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case from.rest {
    [token.Token(kind: token.RArrow, ..), ..rest] -> {
      use to <- result.try(parse_reference.parse(source, rest))

      let span = source.cover(from.span, to.span)

      Ok(cursor.Cursor(
        current: ast.Edge(span:, from: from.current, to: to.current),
        span:,
        rest: to.rest,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, from.rest))

      parse_edge_definition_from(
        source,
        cursor.Cursor(current: from.current, span: from.span, rest:),
      )
    }
  }
}
