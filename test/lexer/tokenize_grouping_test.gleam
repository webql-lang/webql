import gleeunit
import webfn/lexer/token
import webfn/lexer/tokenize_grouping

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_lparen_test() {
  let kind = tokenize_grouping.tokenize(<<"(":utf8>>)

  assert kind == Ok(#(token.LParen, 1))
}

pub fn tokenize_rparen_test() {
  let kind = tokenize_grouping.tokenize(<<")":utf8>>)

  assert kind == Ok(#(token.RParen, 1))
}

pub fn tokenize_lbrace_test() {
  let kind = tokenize_grouping.tokenize(<<"{":utf8>>)

  assert kind == Ok(#(token.LBrace, 1))
}

pub fn tokenize_rbrace_test() {
  let kind = tokenize_grouping.tokenize(<<"}":utf8>>)

  assert kind == Ok(#(token.RBrace, 1))
}

pub fn tokenize_lsquare_test() {
  let kind = tokenize_grouping.tokenize(<<"[":utf8>>)

  assert kind == Ok(#(token.LSquare, 1))
}

pub fn tokenize_rsquare_test() {
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
