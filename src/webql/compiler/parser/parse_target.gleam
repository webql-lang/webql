import gleam/result
import gleam/string
import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses an edge target.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(
  #(ast.Target, source.Span, List(lexer.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)

      parse_node_target(source, name)
    }

    [lexer.Token(kind: lexer.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
      parse_graph_input(source, dot)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_node_target(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.Dot, ..), ..rest] ->
      parse_node_input(source, #(name, span, rest))

    [lexer.Token(kind:, span:), ..] ->
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

fn parse_node_input(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(ast.Input(path: [alias, name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
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

fn parse_graph_input(
  source: String,
  dot: #(Nil, source.Span, List(lexer.Token)),
) {
  let #(_dot, dot_span, rest) = dot

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(ast.Input(path: [name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
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
