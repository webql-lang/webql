import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_primitive
import webql/lang/source

/// Parses an edge output.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Output), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let alias =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_node_output(source, alias)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = cursor.Cursor(current: Nil, span:, rest:)
      parse_operation_output(source, dot)
    }

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_primitive_output(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node_output(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Output), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_output(
        source,
        cursor.Cursor(current: alias.current, span: alias.span, rest:),
      )

    [token.Token(kind:, span:), ..] ->
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

fn parse_node_port_output(
  source: String,
  alias: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Output), diagnostic.Diagnostic) {
  case alias.rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias.span, span)

      Ok(cursor.Cursor(
        current: ast.PortOutput(path: [alias.current, name], span:),
        span:,
        rest:,
      ))
    }

    [token.Token(kind:, span:), ..] ->
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

fn parse_operation_output(
  source: String,
  dot: cursor.Cursor(Nil),
) -> Result(cursor.Cursor(ast.Output), diagnostic.Diagnostic) {
  case dot.rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot.span, span)

      Ok(cursor.Cursor(
        current: ast.PortOutput(path: [name], span:),
        span:,
        rest:,
      ))
    }

    [token.Token(kind:, span:), ..] ->
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

fn parse_primitive_output(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Output), diagnostic.Diagnostic) {
  use cursor.Cursor(current: value, span:, rest:) <- result.try(
    parse_primitive.parse(source, tokens),
  )

  Ok(cursor.Cursor(current: ast.PrimitiveOutput(value:, span:), span:, rest:))
}
