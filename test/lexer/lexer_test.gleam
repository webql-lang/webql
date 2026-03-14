import gleam/list
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
  let groupings = [
    #("(", token.LParen),
    #(")", token.RParen),
    #("{", token.LBrace),
    #("}", token.RBrace),
    #("[", token.LSquare),
    #("]", token.RSquare),
  ]

  list.each(groupings, fn(group) {
    let #(source, expected_kind) = group

    let assert Ok([token, ..]) = lexer.run(lexer.new(source))

    assert token.Token(kind: expected_kind, span: span.Span(start: 0, end: 1))
      == token
  })
}
