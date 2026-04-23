import gleam/result
import gleam/string
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses an edge input.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Input, source.Span, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)

      parse_node_input(source, name)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
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
fn parse_node_input(
  source: String,
  alias: #(String, source.Span, List(token.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_input(source, #(name, span, rest))

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

fn parse_node_port_input(
  source: String,
  alias: #(String, source.Span, List(token.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(ast.PortInput(path: [alias, name], span:), span, rest))
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

fn parse_operation_input(
  source: String,
  dot: #(Nil, source.Span, List(token.Token)),
) {
  let #(_, dot_span, rest) = dot

  case rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(ast.PortInput(path: [name], span:), span, rest))
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
