import webql/lexer
import webql/source

pub fn lex_literals_and_identifiers_test() {
  assert lexer.lex("123 1.5 \"hi\" Name value_2")
    == Ok([
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(kind: lexer.Float, span: source.Span(start: 4, end: 7)),
      lexer.Token(kind: lexer.String, span: source.Span(start: 8, end: 12)),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 13, end: 17),
      ),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 18, end: 25),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 25, end: 25)),
    ])
}

pub fn lex_punctuation_test() {
  assert lexer.lex("(){}[]:,=->.")
    == Ok([
      lexer.Token(kind: lexer.LParen, span: source.Span(start: 0, end: 1)),
      lexer.Token(kind: lexer.RParen, span: source.Span(start: 1, end: 2)),
      lexer.Token(kind: lexer.LBrace, span: source.Span(start: 2, end: 3)),
      lexer.Token(kind: lexer.RBrace, span: source.Span(start: 3, end: 4)),
      lexer.Token(kind: lexer.LSquare, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.RSquare, span: source.Span(start: 5, end: 6)),
      lexer.Token(kind: lexer.Colon, span: source.Span(start: 6, end: 7)),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 7, end: 8)),
      lexer.Token(kind: lexer.Equal, span: source.Span(start: 8, end: 9)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 9, end: 11)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 11, end: 12)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 12, end: 12)),
    ])
}

pub fn lex_ignores_whitespace_and_comments_test() {
  assert lexer.lex("# ignored\n \tvalue")
    == Ok([
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 12, end: 17),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 17, end: 17)),
    ])
}

pub fn lex_reports_invalid_tokens_test() {
  assert lexer.lex("123!")
    == Error(lexer.Diagnostic(
      kind: lexer.IllegalToken,
      span: source.Span(start: 3, end: 4),
    ))
}

pub fn lex_reports_unterminated_strings_test() {
  assert lexer.lex("\"hello")
    == Error(lexer.Diagnostic(
      kind: lexer.UnterminatedString,
      span: source.Span(start: 0, end: 6),
    ))
}

pub fn lex_recovering_preserves_invalid_tokens_test() {
  assert lexer.lex_recovering("123!")
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(
        kind: lexer.Invalid(lexer.IllegalToken),
        span: source.Span(start: 3, end: 4),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4)),
    ]
}
