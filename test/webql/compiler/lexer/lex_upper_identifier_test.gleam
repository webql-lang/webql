import webql/compiler/lexer/lex_upper_identifier
import webql/compiler/lexer/token
import webql/compiler/source

pub fn lex_upper_identifier_stops_correctly_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Testing(":utf8>>, 0, 0)

  assert tok
    == token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 0, end: 7),
    )
  assert rest == <<"(":utf8>>
}

pub fn lex_upper_identifier_allows_letters_and_digits_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Test1,":utf8>>, 4, 0)

  assert tok
    == token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 4, end: 9),
    )
  assert rest == <<",":utf8>>
}

pub fn lex_upper_identifier_stops_on_whitespace_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"TEST rest":utf8>>, 10, 0)

  assert tok
    == token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 10, end: 14),
    )
  assert rest == <<" rest":utf8>>
}

pub fn lex_upper_identifier_stops_before_underscore_test() {
  let #(tok, rest) = lex_upper_identifier.lex(<<"Node_Value":utf8>>, 0, 0)

  assert tok
    == token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 0, end: 4),
    )
  assert rest == <<"_Value":utf8>>
}
