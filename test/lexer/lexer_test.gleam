import gleeunit
import webfn/lexer
import webfn/lexer/span
import webfn/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn run_lexer_on_a_single_integer_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("123"))

  assert token.Token(kind: token.Int, span: span.Span(start: 0, end: 3))
    == token
}

pub fn run_lexer_on_a_single_float_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("1.23"))

  assert token.Token(kind: token.Float, span: span.Span(start: 0, end: 4))
    == token
}

pub fn run_lexer_in_a_single_string_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("\"hello world\""))

  assert token.Token(kind: token.String, span: span.Span(start: 0, end: 13))
    == token
}

pub fn run_lexer_on_all_grouping_chars_test() {
  let assert Ok([l_paren, r_paren, l_brace, r_brace, l_square, r_square, ..]) =
    lexer.run(lexer.new("(){}[]"))

  assert token.Token(kind: token.LParen, span: span.Span(start: 0, end: 1))
    == l_paren

  assert token.Token(kind: token.RParen, span: span.Span(start: 1, end: 2))
    == r_paren

  assert token.Token(kind: token.LBrace, span: span.Span(start: 2, end: 3))
    == l_brace

  assert token.Token(kind: token.RBrace, span: span.Span(start: 3, end: 4))
    == r_brace

  assert token.Token(kind: token.LSquare, span: span.Span(start: 4, end: 5))
    == l_square

  assert token.Token(kind: token.RSquare, span: span.Span(start: 5, end: 6))
    == r_square
}
