import webql/compiler/lexer
import webql/compiler/source

pub fn lex_comment_stops_at_newline_test() {
  let assert Ok(tokens) = lexer.lex("#hello\nworld")

  assert tokens
    == [
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 0, end: 6)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 6, end: 7)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 7, end: 12),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 12, end: 12)),
    ]
}

pub fn lex_comment_stops_at_crlf_test() {
  let assert Ok(tokens) = lexer.lex("#hello\r\nworld")

  assert tokens
    == [
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 0, end: 6)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 6, end: 8)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 8, end: 13),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 13, end: 13)),
    ]
}

pub fn lex_comment_stops_at_cr_test() {
  let assert Ok(tokens) = lexer.lex("#hello\rworld")

  assert tokens
    == [
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 0, end: 6)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 6, end: 7)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 7, end: 12),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 12, end: 12)),
    ]
}

pub fn lex_comment_stops_at_eof_test() {
  let assert Ok(tokens) = lexer.lex("#hello")

  assert tokens
    == [
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 0, end: 6)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 6, end: 6)),
    ]
}

pub fn lex_comment_respects_non_zero_start_test() {
  let assert Ok(tokens) = lexer.lex("test #hello\nworld")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 0, end: 4),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 5, end: 11)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 11, end: 12)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 12, end: 17),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 17, end: 17)),
    ]
}
