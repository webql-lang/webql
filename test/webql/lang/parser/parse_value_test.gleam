import gleam/list
import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_value
import webql/lang/source/position

pub fn parse_values_test() {
  let values = [
    #(
      "123",
      position.Span(start: 0, end: 3),
      ast.IntValue(span: position.Span(start: 0, end: 3), value: 123),
    ),
    #(
      "1.23",
      position.Span(start: 0, end: 4),
      ast.FloatValue(span: position.Span(start: 0, end: 4), value: 1.23),
    ),
    #(
      "\"test\"",
      position.Span(start: 0, end: 6),
      ast.StringValue(span: position.Span(start: 0, end: 6), value: "test"),
    ),
  ]

  list.each(values, fn(value) {
    let #(source, expected_span, expected_value) = value

    let assert Ok(tokens) =
      source
      |> lexer.new()
      |> lexer.lex()

    let assert Ok(ast.Parsed(node: parsed_value, span: span, tokens: rest)) =
      parse_value.parse(source, tokens)

    assert parsed_value == expected_value
    assert span == expected_span

    assert rest
      == [
        token.Token(
          kind: token.EOF,
          span: position.Span(start: expected_span.end, end: expected_span.end),
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

  let assert Ok(ast.Parsed(node: value, span: span, tokens: rest)) =
    parse_value.parse(source, tokens)

  assert value
    == ast.IntValue(span: position.Span(start: 2, end: 5), value: 123)

  assert span == position.Span(start: 2, end: 5)

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 5, end: 5))]
}

pub fn parse_preserves_rest_test() {
  let source = "123 abc"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: value, span: span, tokens: rest)) =
    parse_value.parse(source, tokens)

  assert value
    == ast.IntValue(span: position.Span(start: 0, end: 3), value: 123)

  assert span == position.Span(start: 0, end: 3)

  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 4, end: 7),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 7, end: 7)),
    ]
}

pub fn parse_invalid_float_test() {
  let source = "1.2.3"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_value.parse(source, tokens)

  assert error.kind == diagnostic.UnexpectedToken(token.Float)
  assert error.span == position.Span(start: 0, end: 5)
}
