import gleam/result
import gleam/string
import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_value
import webql/compiler/source

/// Parses an edge source.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(
  #(ast.Source, source.Span, List(lexer.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let alias = #(source.slice(source, span), span, rest)
      parse_node_source(source, alias)
    }

    [lexer.Token(kind: lexer.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
      parse_graph_output(source, dot)
    }

    [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> parse_literal(source, tokens)

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
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.Dot, ..), ..rest] ->
      parse_node_output(source, #(name, span, rest))

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

fn parse_node_output(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(ast.Output(path: [alias, name], span:), span, rest))
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

fn parse_graph_output(
  source: String,
  dot: #(Nil, source.Span, List(lexer.Token)),
) {
  let #(_dot, dot_span, rest) = dot

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(ast.Output(path: [name], span:), span, rest))
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

fn parse_literal(source: String, tokens: List(lexer.Token)) {
  use #(value, span, rest) <- result.try(parse_value.parse(source, tokens))

  Ok(#(ast.Literal(value:, span:), span, rest))
}
