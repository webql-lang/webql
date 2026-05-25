import gleam/bit_array
import webql/compiler/lexer/lex_number
import webql/compiler/lexer/token
import webql/compiler/source

pub fn lex_int_stops_correctly_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("23 abc"), 0, 0)

  assert tok
    == token.Token(kind: token.Int, span: source.Span(start: 0, end: 2))
  assert rest == <<" abc":utf8>>
}

pub fn lex_float_detected_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("23.45;"), 0, 0)

  assert tok
    == token.Token(kind: token.Float, span: source.Span(start: 0, end: 5))
  assert rest == <<";":utf8>>
}

pub fn lex_allows_underscores_in_int_test() {
  let #(tok, rest) = lex_number.lex(bit_array.from_string("2_3x"), 0, 0)

  assert tok
    == token.Token(kind: token.Int, span: source.Span(start: 0, end: 3))
  assert rest == <<"x":utf8>>
}
