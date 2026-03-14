import gleeunit
import webfn/lexer/token
import webfn/lexer/tokenize_grouping

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_lparen_test() {
  let kind = tokenize_grouping.tokenize(<<"(":utf8>>)

  assert kind == token.LParen
}

pub fn tokenize_rparen_test() {
  let kind = tokenize_grouping.tokenize(<<")":utf8>>)

  assert kind == token.RParen
}

pub fn tokenize_lbrace_test() {
  let kind = tokenize_grouping.tokenize(<<"{":utf8>>)

  assert kind == token.LBrace
}

pub fn tokenize_rbrace_test() {
  let kind = tokenize_grouping.tokenize(<<"}":utf8>>)

  assert kind == token.RBrace
}

pub fn tokenize_lsquare_test() {
  let kind = tokenize_grouping.tokenize(<<"[":utf8>>)

  assert kind == token.LSquare
}

pub fn tokenize_rsquare_test() {
  let kind = tokenize_grouping.tokenize(<<"]":utf8>>)

  assert kind == token.RSquare
}

pub fn tokenize_ignores_remaining_bytes_test() {
  let kind = tokenize_grouping.tokenize(<<"(abc":utf8>>)

  assert kind == token.LParen
}
