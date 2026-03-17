import gleeunit
import webfn/lexer/diagnostic
import webfn/lexer/position
import webfn/lexer/symbol
import webfn/lexer/token

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_l_paren_test() {
  let result = symbol.tokenize(<<"(rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.LParen, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_r_paren_test() {
  let result = symbol.tokenize(<<")rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.RParen, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_l_brace_test() {
  let result = symbol.tokenize(<<"{rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.LBrace, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_r_brace_test() {
  let result = symbol.tokenize(<<"}rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.RBrace, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_l_square_test() {
  let result = symbol.tokenize(<<"[rest":utf8>>, 4)

  assert result
    == Ok(
      #(
        token.Token(kind: token.LSquare, span: position.Span(start: 4, end: 5)),
        <<"rest":utf8>>,
      ),
    )
}

pub fn tokenize_r_square_test() {
  let result = symbol.tokenize(<<"]rest":utf8>>, 4)

  assert result
    == Ok(
      #(
        token.Token(kind: token.RSquare, span: position.Span(start: 4, end: 5)),
        <<"rest":utf8>>,
      ),
    )
}

pub fn tokenize_colon_test() {
  let result = symbol.tokenize(<<":rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.Colon, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_comma_test() {
  let result = symbol.tokenize(<<",rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.Comma, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_equal_test() {
  let result = symbol.tokenize(<<"=rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.Equal, span: position.Span(start: 4, end: 5)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_r_arrow_test() {
  let result = symbol.tokenize(<<"->rest":utf8>>, 4)

  assert result
    == Ok(
      #(token.Token(kind: token.RArrow, span: position.Span(start: 4, end: 6)), <<
        "rest":utf8,
      >>),
    )
}

pub fn tokenize_returns_remaining_bytes_correctly_test() {
  let result = symbol.tokenize(<<"(abc":utf8>>, 0)

  assert result
    == Ok(
      #(token.Token(kind: token.LParen, span: position.Span(start: 0, end: 1)), <<
        "abc":utf8,
      >>),
    )
}

pub fn tokenize_fails_on_invalid_test() {
  let result = symbol.tokenize(<<"!rest":utf8>>, 7)

  assert result
    == Error(diagnostic.Diagnostic(
      kind: diagnostic.IllegalToken,
      span: position.Span(start: 7, end: 7),
    ))
}
