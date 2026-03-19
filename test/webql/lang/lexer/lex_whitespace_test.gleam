import gleam/bit_array
import webql/lang/lexer/lex_whitespace
import webql/lang/lexer/token
import webql/lang/source/position

pub fn lex_whitespace_stops_at_non_whitespace_test() {
  let #(tok, rest) =
    lex_whitespace.lex(bit_array.from_string(" \t\n\rhello"), 0, 0)

  assert tok
    == token.Token(kind: token.Space, span: position.Span(start: 0, end: 4))

  let assert <<"hello":utf8>> = rest
}

pub fn lex_whitespace_consumes_until_eof_test() {
  let #(tok, rest) = lex_whitespace.lex(bit_array.from_string(" \t\n\r"), 0, 0)

  assert tok
    == token.Token(kind: token.Space, span: position.Span(start: 0, end: 4))

  assert rest == bit_array.from_string("")
}

pub fn lex_whitespace_respects_non_zero_start_and_size_test() {
  let #(tok, rest) =
    lex_whitespace.lex(bit_array.from_string(" \thello"), 10, 1)

  assert tok
    == token.Token(kind: token.Space, span: position.Span(start: 10, end: 13))

  let assert <<"hello":utf8>> = rest
}
