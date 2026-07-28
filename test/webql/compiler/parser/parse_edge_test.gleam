import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_edge
import webql/compiler/source

pub fn parse_node_port_edge_supernode_test() {
  let source = "m.out -> .out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 13),
      source: ast.Output(span: source.Span(start: 0, end: 5), path: [
        "m",
        "out",
      ]),
      target: ast.Input(span: source.Span(start: 9, end: 13), path: ["out"]),
    )

  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 13, end: 13))]
}

pub fn parse_literal_edge_supernode_test() {
  let source = "\"test\" -> .out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 14),
      source: ast.Literal(
        span: source.Span(start: 0, end: 6),
        value: ast.String(
          name: "String",
          span: source.Span(start: 0, end: 6),
          value: "test",
        ),
      ),
      target: ast.Input(span: source.Span(start: 10, end: 14), path: ["out"]),
    )

  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_preserves_remaining_tokens_after_supernode_test() {
  let source = ".in -> .out extra"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(edge, _, rest)) = parse_edge.parse(source, tokens)

  assert edge
    == ast.Edge(
      span: source.Span(start: 0, end: 11),
      source: ast.Output(span: source.Span(start: 0, end: 3), path: ["in"]),
      target: ast.Input(span: source.Span(start: 7, end: 11), path: ["out"]),
    )

  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 11, end: 12)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 12, end: 17),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 17, end: 17)),
    ]
}

pub fn parse_returns_unexpected_token_for_invalid_supernode_start_test() {
  let source = "Math"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_token_for_upper_identifier_edge_source_test() {
  let source = "Math -> .out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_eof_when_edge_target_is_missing_test() {
  let source = ".in -> "

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 7, end: 7),
    )
}

pub fn parse_returns_unexpected_token_for_literal_edge_target_test() {
  let source = ".in -> \"out\""

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_edge.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.String),
      span: source.Span(start: 7, end: 12),
    )
}
