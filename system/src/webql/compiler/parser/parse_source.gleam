import gleam/result
import gleam/string
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_value
import webql/compiler/source

/// Parses an edge source.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Source, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let alias = #(source.slice(source, span), span, rest)
      parse_node_source(source, alias)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
      parse_graph_output(source, dot)
    }

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> parse_literal(source, tokens)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node_source(
  source: String,
  alias: #(String, source.Span, List(token.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_output(source, #(name, span, rest))

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

fn parse_node_output(
  source: String,
  alias: #(String, source.Span, List(token.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(ast.Output(path: [alias, name], span:), span, rest))
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

fn parse_graph_output(
  source: String,
  dot: #(Nil, source.Span, List(token.Token)),
) {
  let #(_, dot_span, rest) = dot

  case rest {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(ast.Output(path: [name], span:), span, rest))
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

fn parse_literal(source: String, tokens: List(token.Token)) {
  use #(value, span, rest) <- result.try(parse_value.parse(source, tokens))

  Ok(#(ast.Literal(value:, span:), span, rest))
}
