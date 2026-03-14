import gleeunit
import webfn/lexer/token
import webfn/lexer/tokenize_grouping

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_l_paren_test() {
  let kind = tokenize_grouping.tokenize(<<"(":utf8>>)

  assert kind == Ok(#(token.LParen, 1))
}

pub fn tokenize_r_paren_test() {
  let kind = tokenize_grouping.tokenize(<<")":utf8>>)

  assert kind == Ok(#(token.RParen, 1))
}

pub fn tokenize_l_brace_test() {
  let kind = tokenize_grouping.tokenize(<<"{":utf8>>)

  assert kind == Ok(#(token.LBrace, 1))
}

pub fn tokenize_r_brace_test() {
  let kind = tokenize_grouping.tokenize(<<"}":utf8>>)

  assert kind == Ok(#(token.RBrace, 1))
}

pub fn tokenize_l_square_test() {
  let kind = tokenize_grouping.tokenize(<<"[":utf8>>)

  assert kind == Ok(#(token.LSquare, 1))
}

pub fn tokenize_r_square_test() {
  let kind = tokenize_grouping.tokenize(<<"]":utf8>>)

  assert kind == Ok(#(token.RSquare, 1))
}

pub fn tokenize_ignores_remaining_bytes_test() {
  let kind = tokenize_grouping.tokenize(<<"(abc":utf8>>)

  assert kind == Ok(#(token.LParen, 1))
}

pub fn tokenize_fails_on_invalid_test() {
  let error = tokenize_grouping.tokenize(<<"!":utf8>>)

  assert error == Error("Unknown byte recieved while parsing grouping!")
}
