import webql/compiler/lexer/lex_lower_identifier
import webql/compiler/lexer/token
import webql/compiler/source

pub fn lex_lower_identifier_stops_correctly_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test(":utf8>>, 0, 0)

  assert tok
    == token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 0, end: 4),
    )
  assert rest == <<"(":utf8>>
}

pub fn lex_lower_identifier_allows_letters_digits_and_underscore_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test_2,":utf8>>, 4, 0)

  assert tok
    == token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 4, end: 10),
    )
  assert rest == <<",":utf8>>
}

pub fn lex_lower_identifier_stops_on_whitespace_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"test rest":utf8>>, 10, 0)

  assert tok
    == token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 10, end: 14),
    )
  assert rest == <<" rest":utf8>>
}

pub fn lex_lower_identifier_stops_before_uppercase_test() {
  let #(tok, rest) = lex_lower_identifier.lex(<<"mathPort":utf8>>, 0, 0)

  assert tok
    == token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 0, end: 4),
    )
  assert rest == <<"Port":utf8>>
}
