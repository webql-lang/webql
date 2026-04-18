import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source

/// Parses an edge input.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Input), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name =
        cursor.Cursor(current: source.slice(source, span), span:, rest:)

      parse_node_input(source, name)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = cursor.Cursor(current: Nil, span:, rest:)
      parse_operation_input(source, dot)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node_input(source: String, alias: cursor.Cursor(String)) {
  case alias.rest {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_input(
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

fn parse_node_port_input(source: String, alias: cursor.Cursor(String)) {
  case alias.rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias.span, span)

      Ok(cursor.Cursor(
        current: ast.PortInput(path: [alias.current, name], span:),
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

fn parse_operation_input(source: String, dot: cursor.Cursor(Nil)) {
  case dot.rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot.span, span)

      Ok(cursor.Cursor(
        current: ast.PortInput(path: [name], span:),
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
