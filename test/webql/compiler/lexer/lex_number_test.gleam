import webql/compiler/lexer
import webql/compiler/source

pub fn lex_int_stops_correctly_test() {
  let assert Ok(tokens) = lexer.lex("23 abc")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 2)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 2, end: 3)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 3, end: 6),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 6, end: 6)),
    ]
}

pub fn lex_float_detected_test() {
  let assert Ok(tokens) = lexer.lex("23.45,")

  assert tokens
    == [
      lexer.Token(kind: lexer.Float, span: source.Span(start: 0, end: 5)),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 5, end: 6)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 6, end: 6)),
    ]
}

pub fn lex_allows_underscores_in_int_test() {
  let assert Ok(tokens) = lexer.lex("2_3x")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 3, end: 4),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4)),
    ]
}
