import gleam/bit_array
import webql/compiler/lexer/diagnostic
import webql/compiler/lexer/lex_string
import webql/compiler/lexer/token
import webql/compiler/source

pub fn lex_string_stops_correctly_test() {
  let #(tok, rest) =
    lex_string.lex(bit_array.from_string("hello\" world"), 0, 0)

  assert tok
    == token.Token(kind: token.String, span: source.Span(start: 0, end: 6))
  assert rest == <<" world":utf8>>
}

pub fn lex_string_allows_escaped_quote_test() {
  let #(tok, rest) =
    lex_string.lex(bit_array.from_string("hello\\\"world\";"), 0, 0)

  assert tok
    == token.Token(kind: token.String, span: source.Span(start: 0, end: 13))
  assert rest == <<";":utf8>>
}

pub fn lex_string_allows_escaped_characters_test() {
  let #(tok, rest) = lex_string.lex(bit_array.from_string("a\\nb\"."), 0, 0)

  assert tok
    == token.Token(kind: token.String, span: source.Span(start: 0, end: 5))
  assert rest == <<".":utf8>>
}

pub fn lex_string_unterminated_test() {
  let #(tok, rest) = lex_string.lex(bit_array.from_string("hello"), 0, 0)

  assert tok
    == token.Token(
      kind: token.Diagnostic(diagnostic.UnterminatedString),
      span: source.Span(start: 0, end: 5),
    )
  assert rest == <<>>
}

pub fn lex_string_unterminated_after_escape_test() {
  let #(tok, rest) = lex_string.lex(bit_array.from_string("hello\\"), 0, 0)

  assert tok
    == token.Token(
      kind: token.Diagnostic(diagnostic.UnterminatedString),
      span: source.Span(start: 0, end: 6),
    )
  assert rest == <<>>
}

pub fn lex_string_respects_non_zero_start_test() {
  let #(tok, rest) = lex_string.lex(bit_array.from_string("abc\";"), 5, 0)

  assert tok
    == token.Token(kind: token.String, span: source.Span(start: 5, end: 9))
  assert rest == <<";":utf8>>
}

