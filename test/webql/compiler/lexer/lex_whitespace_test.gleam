import webql/compiler/lexer
import webql/compiler/source

pub fn lex_whitespace_stops_at_non_whitespace_test() {
  let assert Ok(tokens) = lexer.tokenize(" \t\n\rhello")

  assert tokens
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 0, end: 4)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 4, end: 9),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 9, end: 9)),
    ]
}

pub fn lex_whitespace_consumes_until_eof_test() {
  let assert Ok(tokens) = lexer.tokenize(" \t\n\r")

  assert tokens
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 0, end: 4)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4)),
    ]
}

pub fn lex_whitespace_respects_non_zero_start_test() {
  let assert Ok(tokens) = lexer.tokenize("1234567890 \thello")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 10)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 10, end: 12)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 12, end: 17),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 17, end: 17)),
    ]
}
