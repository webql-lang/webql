import gleam/bit_array
import gleeunit
import webfn/lexer/token
import webfn/lexer/tokenize_number

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_int_stops_correctly_test() {
  let #(tok, rest) =
    tokenize_number.tokenize(bit_array.from_string("23 abc"), 0, 0)

  let token.Token(kind: kind, span: token.Span(start: start, end: end)) = tok
  let assert token.Int = kind

  assert start == 0
  assert end == 2

  let assert <<" abc":utf8>> = rest
}

pub fn tokenize_float_detected_test() {
  let #(tok, rest) =
    tokenize_number.tokenize(bit_array.from_string("23.45;"), 0, 0)

  let token.Token(kind: kind, span: token.Span(start: start, end: end)) = tok
  let assert token.Float = kind

  assert start == 0
  assert end == 5

  let assert <<";":utf8>> = rest
}

pub fn tokenize_allows_underscores_in_int_test() {
  let #(tok, rest) =
    tokenize_number.tokenize(bit_array.from_string("2_3x"), 0, 0)

  let token.Token(kind: kind, span: token.Span(start: start, end: end)) = tok
  let assert token.Int = kind

  assert start == 0
  assert end == 3

  let assert <<"x":utf8>> = rest
}
