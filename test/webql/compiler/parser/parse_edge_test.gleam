import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_edge
import webql/compiler/source

pub fn parse_node_port_edge_definition_test() {
  let source = "m.out -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 13),
      from: ast.PortOutput(span: source.Span(start: 0, end: 5), path: [
        "m",
        "out",
      ]),
      to: ast.PortInput(span: source.Span(start: 9, end: 13), path: ["out"]),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 13, end: 13))]
}

pub fn parse_literal_edge_definition_test() {
  let source = "\"test\" -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 14),
      from: ast.PrimitiveOutput(
        span: source.Span(start: 0, end: 6),
        value: ast.String(
          name: "String",
          span: source.Span(start: 0, end: 6),
          value: "test",
        ),
      ),
      to: ast.PortInput(span: source.Span(start: 10, end: 14), path: ["out"]),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_preserves_remaining_tokens_after_definition_test() {
  let source = ".in -> .out extra"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 11),
      from: ast.PortOutput(span: source.Span(start: 0, end: 3), path: ["in"]),
      to: ast.PortInput(span: source.Span(start: 7, end: 11), path: ["out"]),
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 11, end: 12)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 12, end: 17),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 17, end: 17)),
    ]
}

pub fn parse_returns_unexpected_token_for_invalid_definition_start_test() {
  let source = "Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_token_for_upper_identifier_edge_source_test() {
  let source = "Math -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_eof_when_edge_target_is_missing_test() {
  let source = ".in -> "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 7, end: 7),
    )
}

pub fn parse_returns_unexpected_token_for_primitive_edge_target_test() {
  let source = ".in -> \"out\""

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.String),
      span: source.Span(start: 7, end: 12),
    )
}
