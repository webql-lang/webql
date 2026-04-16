import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_definition
import webql/lang/source

pub fn parse_binding_definition_test() {
  let source = "m = Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens)

  assert definition
    == ast.Binding(
      span: source.Span(start: 0, end: 8),
      name: "m",
      value: ast.Node(name: "Math", span: source.Span(start: 4, end: 8)),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 8, end: 8))]
}

pub fn parse_node_port_edge_definition_test() {
  let source = "m.out -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens)

  assert definition
    == ast.Edge(
      span: source.Span(start: 0, end: 13),
      from: ast.OutputAccess(span: source.Span(start: 0, end: 5), path: [
        "m",
        "out",
      ]),
      to: ast.InputAccess(span: source.Span(start: 9, end: 13), path: ["out"]),
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

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens)

  assert definition
    == ast.Edge(
      span: source.Span(start: 0, end: 14),
      from: ast.Literal(
        span: source.Span(start: 0, end: 6),
        value: ast.String(span: source.Span(start: 0, end: 6), value: "test"),
      ),
      to: ast.InputAccess(span: source.Span(start: 10, end: 14), path: ["out"]),
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

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens)

  assert definition
    == ast.Edge(
      span: source.Span(start: 0, end: 11),
      from: ast.InputAccess(span: source.Span(start: 0, end: 3), path: ["in"]),
      to: ast.InputAccess(span: source.Span(start: 7, end: 11), path: ["out"]),
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

  let assert Error(error) = parse_definition.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_eof_when_binding_value_is_missing_test() {
  let source = "m = "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_definition.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 4, end: 4),
    )
}

pub fn parse_returns_unexpected_eof_when_edge_target_is_missing_test() {
  let source = ".in -> "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_definition.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 7, end: 7),
    )
}
