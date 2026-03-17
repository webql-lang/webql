import gleam/bit_array
import gleeunit
import webql/lexer/diagnostic
import webql/lexer/lex_string
import webql/lexer/position
import webql/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn lex_string_stops_correctly_test() {
  let assert Ok(#(tok, rest)) =
    lex_string.lex(bit_array.from_string("hello\" world"), 0, 0)

  let token.Token(kind: kind, span: position.Span(start: start, end: end)) = tok
  let assert token.String = kind

  assert start == 0
  assert end == 6

  let assert <<" world":utf8>> = rest
}

pub fn lex_string_allows_escaped_quote_test() {
  let assert Ok(#(tok, rest)) =
    lex_string.lex(bit_array.from_string("hello\\\"world\";"), 0, 0)

  let token.Token(kind: kind, span: position.Span(start: start, end: end)) = tok
  let assert token.String = kind

  assert start == 0
  assert end == 13

  let assert <<";":utf8>> = rest
}

pub fn lex_string_allows_escaped_characters_test() {
  let assert Ok(#(tok, rest)) =
    lex_string.lex(bit_array.from_string("a\\nb\"."), 0, 0)

  let token.Token(kind: kind, span: position.Span(start: start, end: end)) = tok
  let assert token.String = kind

  assert start == 0
  assert end == 5

  let assert <<".":utf8>> = rest
}

pub fn lex_string_unterminated_test() {
  let assert Error(diagnostic.Diagnostic(
    kind: kind,
    span: position.Span(start: start, end: end),
  )) = lex_string.lex(bit_array.from_string("hello"), 0, 0)

  let assert diagnostic.UnterminatedString = kind

  assert start == 0
  assert end == 5
}

pub fn lex_string_unterminated_after_escape_test() {
  let assert Error(diagnostic.Diagnostic(
    kind: kind,
    span: position.Span(start: start, end: end),
  )) = lex_string.lex(bit_array.from_string("hello\\"), 0, 0)

  let assert diagnostic.UnterminatedString = kind

  assert start == 0
  assert end == 6
}

pub fn lex_string_respects_non_zero_start_test() {
  let assert Ok(#(tok, rest)) =
    lex_string.lex(bit_array.from_string("abc\";"), 5, 0)

  let token.Token(kind: kind, span: position.Span(start: start, end: end)) = tok
  let assert token.String = kind

  assert start == 5
  assert end == 9

  let assert <<";":utf8>> = rest
}
