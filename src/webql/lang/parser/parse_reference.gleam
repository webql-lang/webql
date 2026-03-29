import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_value

pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Reference, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] ->
      parse_node_port_reference(
        source,
        rest,
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        ),
      )

    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_operation_port_reference(source, rest)

    [token.Token(kind: token.Int, ..), ..] ->
      parse_value_reference(source, tokens)

    [token.Token(kind: token.Float, ..), ..] ->
      parse_value_reference(source, tokens)

    [token.Token(kind: token.String, ..), ..] ->
      parse_value_reference(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_node_port_reference(
  source: String,
  tokens: List(token.Token),
  alias: String,
) -> Result(#(ast.Reference, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Dot, ..), ..rest] ->
      parse_node_port_reference_port(source, rest, alias)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_node_port_reference(source, tokens, alias)
    }
  }
}

fn parse_node_port_reference_port(
  source: String,
  tokens: List(token.Token),
  alias: String,
) -> Result(#(ast.Reference, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let port =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      Ok(#(ast.NodePortReference(alias:, port:), rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_node_port_reference_port(source, tokens, alias)
    }
  }
}

fn parse_operation_port_reference(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Reference, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span: span), ..rest] -> {
      let port =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      Ok(#(ast.OperationPortReference(port:), rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse_operation_port_reference(source, tokens)
    }
  }
}

fn parse_value_reference(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Reference, List(token.Token)), diagnostic.Diagnostic) {
  use #(value, tokens) <- result.try(parse_value.parse(source, tokens))
  Ok(#(ast.ValueReference(value: value), tokens))
}
