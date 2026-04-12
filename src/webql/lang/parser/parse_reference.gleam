import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_primitive
import webql/lang/source

/// Parses a reference.
///
/// ## Examples
///
///     m.out
///     .out
///     "test"
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let alias =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_node_port_reference(source, alias)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = cursor.Cursor(current: Nil, span:, rest:)
      parse_operation_port_reference(source, dot)
    }

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_primitive_reference(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node_port_reference(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_reference_port(
        source,
        cursor.Cursor(current: alias.current, span: alias.span, rest:),
      )

    [token.Token(kind: kind, span:), ..] ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedToken(kind:),
        span:,
      ))

    [] -> {
      let length = string.length(source)

      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: length, end: length),
      ))
    }
  }
}

fn parse_node_port_reference_port(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.LowerIdentifier, ..) as name, ..rest] -> {
      let port = source.slice(source, name.span)
      let span = source.cover(alias.span, name.span)

      Ok(cursor.Cursor(
        current: ast.Access(path: [alias.current, port], span:),
        span:,
        rest:,
      ))
    }

    [token.Token(kind: kind, span:), ..] ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnexpectedToken(kind), span:))

    [] -> {
      let length = string.length(source)

      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: length, end: length),
      ))
    }
  }
}

fn parse_operation_port_reference(
  source: String,
  dot: cursor.Cursor(Nil),
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  case dot.rest {
    [token.Token(kind: token.LowerIdentifier, ..) as tok, ..rest] -> {
      let port = source.slice(source, tok.span)
      let span = source.cover(dot.span, tok.span)

      Ok(cursor.Cursor(current: ast.Access(path: [port], span:), span:, rest:))
    }

    [token.Token(kind: kind, span:), ..] ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnexpectedToken(kind), span:))

    [] -> {
      let length = string.length(source)

      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnexpectedEof,
        span: source.Span(start: length, end: length),
      ))
    }
  }
}

fn parse_primitive_reference(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  use cursor.Cursor(current: value, span:, rest:) <- result.try(
    parse_primitive.parse(source, tokens),
  )

  Ok(cursor.Cursor(current: ast.Literal(span:, value:), span:, rest:))
}
