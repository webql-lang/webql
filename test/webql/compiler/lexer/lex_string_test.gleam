import webql/compiler/lexer
import webql/compiler/source

pub fn lex_string_stops_correctly_test() {
  let assert Ok(tokens) = lexer.lex("\"hello\" world")

  assert tokens
    == [
      lexer.Token(kind: lexer.String, span: source.Span(start: 0, end: 7)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 7, end: 8)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 8, end: 13),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 13, end: 13)),
    ]
}

pub fn lex_string_allows_escaped_quote_test() {
  let assert Ok(tokens) = lexer.lex("\"hello\\\"world\".")

  assert tokens
    == [
      lexer.Token(kind: lexer.String, span: source.Span(start: 0, end: 14)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 14, end: 15)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 15, end: 15)),
    ]
}

pub fn lex_string_allows_escaped_characters_test() {
  let assert Ok(tokens) = lexer.lex("\"a\\nb\".")

  assert tokens
    == [
      lexer.Token(kind: lexer.String, span: source.Span(start: 0, end: 6)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 6, end: 7)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 7, end: 7)),
    ]
}

pub fn lex_string_unterminated_test() {
  let tokens = lexer.lex_recovering("\"hello")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.Invalid(lexer.UnterminatedString),
        span: source.Span(start: 0, end: 6),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 6, end: 6)),
    ]
}

pub fn lex_string_unterminated_after_escape_test() {
  let tokens = lexer.lex_recovering("\"hello\\")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.Invalid(lexer.UnterminatedString),
        span: source.Span(start: 0, end: 7),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 7, end: 7)),
    ]
}

pub fn lex_string_respects_non_zero_start_test() {
  let assert Ok(tokens) = lexer.lex("1234 \"abc\",")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 4)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.String, span: source.Span(start: 5, end: 10)),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 10, end: 11)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 11, end: 11)),
    ]
}
