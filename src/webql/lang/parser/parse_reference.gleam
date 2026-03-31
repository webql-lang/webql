import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_value
import webql/lang/source

pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let alias =
        ast.Parsed(node: source.slice(source, span), span:, tokens: rest)

      parse_node_port_reference(source, alias)
    }

    [token.Token(kind: token.Dot, span:), ..rest] -> {
      let dot = ast.Parsed(node: Nil, span:, tokens: rest)
      parse_operation_port_reference(source, dot)
    }

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_value_reference(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_node_port_reference(
  source: String,
  alias: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  case alias.tokens {
    [token.Token(kind: token.Dot, ..), ..tokens] ->
      parse_node_port_reference_port(
        source,
        ast.Parsed(node: alias.node, span: alias.span, tokens:),
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
  alias: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  case alias.tokens {
    [token.Token(kind: token.LowerIdentifier, ..) as name, ..rest] -> {
      let port = source.slice(source, name.span)
      let span = source.cover(alias.span, name.span)

      Ok(ast.Parsed(
        node: ast.NodePortReference(span:, alias: alias.node, port:),
        span:,
        tokens: rest,
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
  dot: ast.Parsed(Nil),
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  case dot.tokens {
    [token.Token(kind: token.LowerIdentifier, ..) as token, ..tokens] -> {
      let port = source.slice(source, token.span)
      let span = source.cover(dot.span, token.span)

      Ok(ast.Parsed(
        node: ast.OperationPortReference(span:, port:),
        span:,
        tokens:,
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

fn parse_value_reference(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  use ast.Parsed(node: value, span:, tokens:) <- result.try(parse_value.parse(
    source,
    tokens,
  ))

  Ok(ast.Parsed(node: ast.ValueReference(span:, value:), span:, tokens:))
}
