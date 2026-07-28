import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_value
import webql/compiler/source

pub fn parse_int_literal_test() {
  let source = "123"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert value
    == ast.Int(name: "Int", span: source.Span(start: 0, end: 3), value: 123)
  assert span == source.Span(start: 0, end: 3)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 3, end: 3))]
}

pub fn parse_float_literal_test() {
  let source = "1.23"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert value
    == ast.Float(
      name: "Float",
      span: source.Span(start: 0, end: 4),
      value: 1.23,
    )
  assert span == source.Span(start: 0, end: 4)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_string_literal_test() {
  let source = "\"test\""

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert value
    == ast.String(
      name: "String",
      span: source.Span(start: 0, end: 6),
      value: "test",
    )
  assert span == source.Span(start: 0, end: 6)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 6, end: 6))]
}

pub fn parse_skips_space_test() {
  let source = "  123"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert value
    == ast.Int(name: "Int", span: source.Span(start: 2, end: 5), value: 123)
  assert span == source.Span(start: 2, end: 5)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 5, end: 5))]
}

pub fn parse_preserves_rest_test() {
  let source = "123 abc"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert value
    == ast.Int(name: "Int", span: source.Span(start: 0, end: 3), value: 123)
  assert span == source.Span(start: 0, end: 3)
  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 3, end: 4)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 4, end: 7),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 7, end: 7)),
    ]
}

pub fn parse_invalid_float_test() {
  let source = "1.2.3"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(diagnostic.Diagnostic(kind:, span:)) =
    parse_value.parse(source, tokens)

  assert kind == diagnostic.UnexpectedToken(lexer.Float)
  assert span == source.Span(start: 0, end: 5)
}
