import gleeunit
import webql/lexer
import webql/lexer/position
import webql/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn run_lexer_on_a_single_integer_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("123"))

  assert token.Token(kind: token.Int, span: position.Span(start: 0, end: 3))
    == token
}

pub fn run_lexer_on_a_single_float_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("1.23"))

  assert token.Token(kind: token.Float, span: position.Span(start: 0, end: 4))
    == token
}

pub fn run_lexer_in_a_single_string_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("\"hello world\""))

  assert token.Token(kind: token.String, span: position.Span(start: 0, end: 13))
    == token
}

pub fn run_lexer_on_the_full_symbol_set_test() {
  let assert Ok([
    l_paren,
    r_paren,
    l_brace,
    r_brace,
    l_square,
    r_square,
    colon,
    comma,
    equal,
    r_arrow,
    ..
  ]) = lexer.run(lexer.new("(){}[]:,=->"))

  assert token.Token(kind: token.LParen, span: position.Span(start: 0, end: 1))
    == l_paren

  assert token.Token(kind: token.RParen, span: position.Span(start: 1, end: 2))
    == r_paren

  assert token.Token(kind: token.LBrace, span: position.Span(start: 2, end: 3))
    == l_brace

  assert token.Token(kind: token.RBrace, span: position.Span(start: 3, end: 4))
    == r_brace

  assert token.Token(kind: token.LSquare, span: position.Span(start: 4, end: 5))
    == l_square

  assert token.Token(kind: token.RSquare, span: position.Span(start: 5, end: 6))
    == r_square

  assert token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7))
    == colon

  assert token.Token(kind: token.Comma, span: position.Span(start: 7, end: 8))
    == comma

  assert token.Token(kind: token.Equal, span: position.Span(start: 8, end: 9))
    == equal

  assert token.Token(kind: token.RArrow, span: position.Span(start: 9, end: 11))
    == r_arrow
}

pub fn run_lexer_on_a_single_comment_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new("# hello"))

  assert token.Token(
      kind: token.CommentSingle,
      span: position.Span(start: 0, end: 7),
    )
    == token
}

pub fn run_lexer_on_a_single_whitespace_test() {
  let assert Ok([token, ..]) = lexer.run(lexer.new(" \t\n"))

  assert token.Token(kind: token.Space, span: position.Span(start: 0, end: 3))
    == token
}

pub fn run_lexer_skips_comments_when_disabled_test() {
  let lexer = lexer.comments(lexer.new("# hello\n123"), enabled: False)

  let assert Ok([space, int, eof]) = lexer.run(lexer)

  assert token.Token(kind: token.Space, span: position.Span(start: 7, end: 8))
    == space

  assert token.Token(kind: token.Int, span: position.Span(start: 8, end: 11))
    == int

  assert token.Token(kind: token.EOF, span: position.Span(start: 0, end: 0))
    == eof
}

pub fn run_lexer_skips_whitespace_when_disabled_test() {
  let lexer = lexer.whitespace(lexer.new(" \t123"), enabled: False)

  let assert Ok([int, eof]) = lexer.run(lexer)

  assert token.Token(kind: token.Int, span: position.Span(start: 2, end: 5))
    == int

  assert token.Token(kind: token.EOF, span: position.Span(start: 0, end: 0))
    == eof
}

pub fn run_lexer_skips_comments_and_whitespace_when_disabled_test() {
  let lexer =
    lexer.new("# hello\n\t123")
    |> lexer.comments(enabled: False)
    |> lexer.whitespace(enabled: False)

  let assert Ok([int, eof]) = lexer.run(lexer)

  assert token.Token(kind: token.Int, span: position.Span(start: 9, end: 12))
    == int

  assert token.Token(kind: token.EOF, span: position.Span(start: 0, end: 0))
    == eof
}
