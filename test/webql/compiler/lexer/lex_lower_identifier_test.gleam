import webql/compiler/lexer
import webql/compiler/source

pub fn lex_lower_identifier_stops_correctly_test() {
  let assert Ok(tokens) = lexer.lex("test(")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 0, end: 4),
      ),
      lexer.Token(kind: lexer.LParen, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 5, end: 5)),
    ]
}

pub fn lex_lower_identifier_allows_letters_digits_and_underscore_test() {
  let assert Ok(tokens) = lexer.lex("123 test_2,")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 3, end: 4)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 4, end: 10),
      ),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 10, end: 11)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 11, end: 11)),
    ]
}

pub fn lex_lower_identifier_stops_on_whitespace_test() {
  let assert Ok(tokens) = lexer.lex("1234567890test rest")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 10)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 10, end: 14),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 15, end: 19),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 19, end: 19)),
    ]
}

pub fn lex_lower_identifier_stops_before_uppercase_test() {
  let assert Ok(tokens) = lexer.lex("mathPort")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 0, end: 4),
      ),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 4, end: 8),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 8, end: 8)),
    ]
}
