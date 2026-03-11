import gleeunit
import webfn/lexer
import webfn/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn run_lexer_on_a_single_integer_test() {
  let assert [token, ..] = lexer.run(lexer.new("123"))

  assert token.Token(kind: token.Int, span: token.Span(start: 0, end: 3))
    == token
}

pub fn run_lexer_on_a_single_float_test() {
  let assert [token, ..] = lexer.run(lexer.new("1.23"))

  assert token.Token(kind: token.Float, span: token.Span(start: 0, end: 4))
    == token
}
