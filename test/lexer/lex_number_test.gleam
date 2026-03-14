import gleam/bit_array
import gleeunit
import webfn/lexer/lex_number
import webfn/lexer/span
import webfn/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn lex_int_stops_correctly_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("23 abc"), 0, 0)

  let token.Token(kind: kind, span: span.Span(start: start, end: end)) = tok
  let assert token.Int = kind

  assert start == 0
  assert end == 2

  let assert <<" abc":utf8>> = rest
}

pub fn lex_float_detected_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("23.45;"), 0, 0)

  let token.Token(kind: kind, span: span.Span(start: start, end: end)) = tok
  let assert token.Float = kind

  assert start == 0
  assert end == 5

  let assert <<";":utf8>> = rest
}

pub fn lex_allows_underscores_in_int_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("2_3x"), 0, 0)

  let token.Token(kind: kind, span: span.Span(start: start, end: end)) = tok
  let assert token.Int = kind

  assert start == 0
  assert end == 3

  let assert <<"x":utf8>> = rest
}
