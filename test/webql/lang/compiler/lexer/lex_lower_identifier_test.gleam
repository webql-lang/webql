import webql/lang/compiler/lexer/lex_lower_identifier
import webql/lang/compiler/lexer/token
import webql/lang/compiler/source

pub fn lex_lower_identifier_stops_correctly_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test(":utf8>>, 0, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.LowerIdentifier = kind

  assert start == 0
  assert end == 4

  let assert <<"(":utf8>> = rest
}

pub fn lex_lower_identifier_allows_letters_digits_and_underscore_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test_2,":utf8>>, 4, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.LowerIdentifier = kind

  assert start == 4
  assert end == 10

  let assert <<",":utf8>> = rest
}

pub fn lex_lower_identifier_stops_on_whitespace_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test rest":utf8>>, 10, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.LowerIdentifier = kind

  assert start == 10
  assert end == 14

  let assert <<" rest":utf8>> = rest
}

pub fn lex_lower_identifier_stops_before_uppercase_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"mathPort":utf8>>, 0, 0)

  let token.Token(kind: kind, span: source.Span(start: start, end: end)) = tok
  let assert token.LowerIdentifier = kind

  assert start == 0
  assert end == 4

  let assert <<"Port":utf8>> = rest
}
