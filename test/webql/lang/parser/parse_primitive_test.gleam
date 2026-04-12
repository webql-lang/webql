import gleam/list
import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_primitive
import webql/lang/source

pub fn parse_primitives_test() {
  let values = [
    #(
      "123",
      source.Span(start: 0, end: 3),
      ast.Int(span: source.Span(start: 0, end: 3), value: 123),
    ),
    #(
      "1.23",
      source.Span(start: 0, end: 4),
      ast.Float(span: source.Span(start: 0, end: 4), value: 1.23),
    ),
    #(
      "\"test\"",
      source.Span(start: 0, end: 6),
      ast.String(span: source.Span(start: 0, end: 6), value: "test"),
    ),
  ]

  list.each(values, fn(value) {
    let #(source, expected_span, expected_value) = value

    let assert Ok(tokens) =
      source
      |> lexer.new()
      |> lexer.lex()

    let assert Ok(cursor.Cursor(current: parsed_value, span:, rest:)) =
      parse_primitive.parse(source, tokens)

    assert parsed_value == expected_value
    assert span == expected_span

    assert rest
      == [
        token.Token(
          kind: token.EOF,
          span: source.Span(start: expected_span.end, end: expected_span.end),
        ),
      ]
  })
}

pub fn parse_skips_space_test() {
  let source = "  123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: value, span:, rest:)) =
    parse_primitive.parse(source, tokens)

  assert value == ast.Int(span: source.Span(start: 2, end: 5), value: 123)

  assert span == source.Span(start: 2, end: 5)

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 5, end: 5))]
}

pub fn parse_preserves_rest_test() {
  let source = "123 abc"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: value, span:, rest:)) =
    parse_primitive.parse(source, tokens)

  assert value == ast.Int(span: source.Span(start: 0, end: 3), value: 123)

  assert span == source.Span(start: 0, end: 3)

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 3, end: 4)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 4, end: 7),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 7, end: 7)),
    ]
}

pub fn parse_invalid_float_test() {
  let source = "1.2.3"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(diagnostic.Diagnostic(kind:, span:)) =
    parse_primitive.parse(source, tokens)

  assert kind == diagnostic.UnexpectedToken(token.Float)
  assert span == source.Span(start: 0, end: 5)
}
