import gleam/list
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_value
import webql/lang/source/position

pub fn parse_values_test() {
  let values = [
    #(
      "123",
      [token.Token(kind: token.Int, span: position.Span(start: 0, end: 3))],
      ast.IntValue(value: 123),
    ),
    #(
      "1.23",
      [token.Token(kind: token.Float, span: position.Span(start: 0, end: 4))],
      ast.FloatValue(value: 1.23),
    ),
    #(
      "\"test\"",
      [token.Token(kind: token.String, span: position.Span(start: 0, end: 6))],
      ast.StringValue(value: "test"),
    ),
  ]

  list.each(values, fn(value) {
    let #(source, tokens, expected) = value

    let assert Ok(#(value, rest)) = parse_value.parse(source, tokens)

    assert value == expected
    assert rest == []
  })
}

pub fn parse_skips_space_test() {
  let source = "  123"

  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 2)),
    token.Token(kind: token.Int, span: position.Span(start: 2, end: 5)),
  ]

  let assert Ok(#(value, _)) = parse_value.parse(source, tokens)

  assert value == ast.IntValue(value: 123)
}

pub fn parse_preserves_rest_test() {
  let source = "123 abc"

  let tokens = [
    token.Token(kind: token.Int, span: position.Span(start: 0, end: 3)),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 4, end: 7),
    ),
  ]

  let assert Ok(#(_, rest)) = parse_value.parse(source, tokens)

  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 4, end: 7),
      ),
    ]
}

pub fn parse_invalid_float_test() {
  let source = "1.2.3"

  let tokens = [
    token.Token(kind: token.Float, span: position.Span(start: 0, end: 5)),
  ]

  let assert Error(error) = parse_value.parse(source, tokens)

  assert error.kind == diagnostic.UnexpectedToken(token.Float)
  assert error.span == position.Span(start: 0, end: 5)
}
