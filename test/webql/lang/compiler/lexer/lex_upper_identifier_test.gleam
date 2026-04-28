import webql/lang/compiler/lexer/lex_upper_identifier
import webql/lang/compiler/lexer/token
import webql/lang/compiler/source

pub fn lex_upper_identifier_stops_correctly_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Testing(":utf8>>, 0, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.UpperIdentifier = kind

  assert start == 0
  assert end == 7

  let assert <<"(":utf8>> = rest
}

pub fn lex_upper_identifier_allows_letters_and_digits_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Test1,":utf8>>, 4, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.UpperIdentifier = kind

  assert start == 4
  assert end == 9

  let assert <<",":utf8>> = rest
}

pub fn lex_upper_identifier_stops_on_whitespace_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"TEST rest":utf8>>, 10, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.UpperIdentifier = kind

  assert start == 10
  assert end == 14

  let assert <<" rest":utf8>> = rest
}

pub fn lex_upper_identifier_stops_before_underscore_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Node_Value":utf8>>, 0, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.UpperIdentifier = kind

  assert start == 0
  assert end == 4

  let assert <<"_Value":utf8>> = rest
}
