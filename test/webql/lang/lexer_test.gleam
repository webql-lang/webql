import webql/lang/lexer
import webql/lang/lexer/diagnostic
import webql/lang/lexer/token
import webql/lang/source/position

pub fn run_lexer_on_empty_input_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new(""))

  assert tokens
    == [
      token.Token(kind: token.EOF, span: position.Span(start: 0, end: 0)),
    ]
}

pub fn run_lexer_on_a_single_integer_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("123"))

  assert tokens
    == [
      token.Token(kind: token.Int, span: position.Span(start: 0, end: 3)),
      token.Token(kind: token.EOF, span: position.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_single_float_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("1.23"))

  assert tokens
    == [
      token.Token(kind: token.Float, span: position.Span(start: 0, end: 4)),
      token.Token(kind: token.EOF, span: position.Span(start: 4, end: 4)),
    ]
}

pub fn run_lexer_on_a_single_string_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("\"hello world\""))

  assert tokens
    == [
      token.Token(kind: token.String, span: position.Span(start: 0, end: 13)),
      token.Token(kind: token.EOF, span: position.Span(start: 13, end: 13)),
    ]
}

pub fn run_lexer_on_the_full_symbol_set_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("(){}[]:,=->."))

  assert tokens
    == [
      token.Token(kind: token.LParen, span: position.Span(start: 0, end: 1)),
      token.Token(kind: token.RParen, span: position.Span(start: 1, end: 2)),
      token.Token(kind: token.LBrace, span: position.Span(start: 2, end: 3)),
      token.Token(kind: token.RBrace, span: position.Span(start: 3, end: 4)),
      token.Token(kind: token.LSquare, span: position.Span(start: 4, end: 5)),
      token.Token(kind: token.RSquare, span: position.Span(start: 5, end: 6)),
      token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
      token.Token(kind: token.Comma, span: position.Span(start: 7, end: 8)),
      token.Token(kind: token.Equal, span: position.Span(start: 8, end: 9)),
      token.Token(kind: token.RArrow, span: position.Span(start: 9, end: 11)),
      token.Token(kind: token.Dot, span: position.Span(start: 11, end: 12)),
      token.Token(kind: token.EOF, span: position.Span(start: 12, end: 12)),
    ]
}

pub fn run_lexer_on_a_single_comment_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("# hello"))

  assert tokens
    == [
      token.Token(
        kind: token.CommentSingle,
        span: position.Span(start: 0, end: 7),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 7, end: 7)),
    ]
}

pub fn run_lexer_on_a_single_whitespace_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new(" \t\n"))

  assert tokens
    == [
      token.Token(kind: token.Space, span: position.Span(start: 0, end: 3)),
      token.Token(kind: token.EOF, span: position.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_mixed_stream_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("(123) -> \"hi\", # ok\n[]"))

  assert tokens
    == [
      token.Token(kind: token.LParen, span: position.Span(start: 0, end: 1)),
      token.Token(kind: token.Int, span: position.Span(start: 1, end: 4)),
      token.Token(kind: token.RParen, span: position.Span(start: 4, end: 5)),
      token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
      token.Token(kind: token.RArrow, span: position.Span(start: 6, end: 8)),
      token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
      token.Token(kind: token.String, span: position.Span(start: 9, end: 13)),
      token.Token(kind: token.Comma, span: position.Span(start: 13, end: 14)),
      token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
      token.Token(
        kind: token.CommentSingle,
        span: position.Span(start: 15, end: 19),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 19, end: 20)),
      token.Token(kind: token.LSquare, span: position.Span(start: 20, end: 21)),
      token.Token(kind: token.RSquare, span: position.Span(start: 21, end: 22)),
      token.Token(kind: token.EOF, span: position.Span(start: 22, end: 22)),
    ]
}

pub fn run_lexer_skips_comments_when_disabled_test() {
  let lexer = lexer.with_comments(lexer.new("# hello\n123"), enabled: False)

  let assert Ok(tokens) = lexer.lex(lexer)

  assert tokens
    == [
      token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
      token.Token(kind: token.Int, span: position.Span(start: 8, end: 11)),
      token.Token(kind: token.EOF, span: position.Span(start: 11, end: 11)),
    ]
}

pub fn run_lexer_skips_whitespace_when_disabled_test() {
  let lexer = lexer.with_whitespace(lexer.new(" \t123"), enabled: False)

  let assert Ok(tokens) = lexer.lex(lexer)

  assert tokens
    == [
      token.Token(kind: token.Int, span: position.Span(start: 2, end: 5)),
      token.Token(kind: token.EOF, span: position.Span(start: 5, end: 5)),
    ]
}

pub fn run_lexer_skips_comments_and_whitespace_when_disabled_test() {
  let lexer =
    lexer.new("# hello\n\t123")
    |> lexer.with_comments(enabled: False)
    |> lexer.with_whitespace(enabled: False)

  let assert Ok(tokens) = lexer.lex(lexer)

  assert tokens
    == [
      token.Token(kind: token.Int, span: position.Span(start: 9, end: 12)),
      token.Token(kind: token.EOF, span: position.Span(start: 12, end: 12)),
    ]
}

pub fn run_lexer_on_a_single_upper_identifier_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("Abc"))

  assert tokens
    == [
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 0, end: 3),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_single_lower_identifier_test() {
  let assert Ok(tokens) = lexer.lex(lexer.new("abc_2"))

  assert tokens
    == [
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 0, end: 5),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 5, end: 5)),
    ]
}

pub fn run_lexer_fails_on_invalid_symbol_test() {
  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.IllegalToken,
    span: position.Span(start: 0, end: 1),
  )) = lexer.lex(lexer.new("!"))
}

pub fn run_lexer_fails_on_invalid_symbol_after_valid_tokens_test() {
  let assert Error(diagnostic.Diagnostic(
    kind: diagnostic.IllegalToken,
    span: position.Span(start: 3, end: 4),
  )) = lexer.lex(lexer.new("123!"))
}

pub fn run_lexer_recovers_on_invalid_symbol_test() {
  let lexer = lexer.with_mode(lexer.new("!"), lexer.RecoverOnError)

  let assert Ok(tokens) = lexer.lex(lexer)

  assert tokens
    == [
      token.Token(
        kind: token.Diagnostic(diagnostic.IllegalToken),
        span: position.Span(start: 0, end: 1),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 1, end: 1)),
    ]
}

pub fn run_lexer_recovers_on_invalid_symbol_after_valid_tokens_test() {
  let lexer = lexer.with_mode(lexer.new("123!"), lexer.RecoverOnError)

  let assert Ok(tokens) = lexer.lex(lexer)

  assert tokens
    == [
      token.Token(kind: token.Int, span: position.Span(start: 0, end: 3)),
      token.Token(
        kind: token.Diagnostic(diagnostic.IllegalToken),
        span: position.Span(start: 3, end: 4),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 4, end: 4)),
    ]
}

pub fn run_lexer_on_basic_syntax_test() {
  let source =
    "Addition = in: Int -> out: Int {
  m = Math

  \"addition\"->m.operation
  1->m.lhs
  .in->m.rhs

  m.out->.out
}"

  let assert Ok(tokens) = lexer.lex(lexer.new(source))

  assert tokens
    == [
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 0, end: 8),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
      token.Token(kind: token.Equal, span: position.Span(start: 9, end: 10)),
      token.Token(kind: token.Space, span: position.Span(start: 10, end: 11)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 11, end: 13),
      ),
      token.Token(kind: token.Colon, span: position.Span(start: 13, end: 14)),
      token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 15, end: 18),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 18, end: 19)),
      token.Token(kind: token.RArrow, span: position.Span(start: 19, end: 21)),
      token.Token(kind: token.Space, span: position.Span(start: 21, end: 22)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 22, end: 25),
      ),
      token.Token(kind: token.Colon, span: position.Span(start: 25, end: 26)),
      token.Token(kind: token.Space, span: position.Span(start: 26, end: 27)),
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 27, end: 30),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 30, end: 31)),
      token.Token(kind: token.LBrace, span: position.Span(start: 31, end: 32)),
      token.Token(kind: token.Space, span: position.Span(start: 32, end: 35)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 35, end: 36),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 36, end: 37)),
      token.Token(kind: token.Equal, span: position.Span(start: 37, end: 38)),
      token.Token(kind: token.Space, span: position.Span(start: 38, end: 39)),
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 39, end: 43),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 43, end: 47)),
      token.Token(kind: token.String, span: position.Span(start: 47, end: 57)),
      token.Token(kind: token.RArrow, span: position.Span(start: 57, end: 59)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 59, end: 60),
      ),
      token.Token(kind: token.Dot, span: position.Span(start: 60, end: 61)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 61, end: 70),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 70, end: 73)),
      token.Token(kind: token.Int, span: position.Span(start: 73, end: 74)),
      token.Token(kind: token.RArrow, span: position.Span(start: 74, end: 76)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 76, end: 77),
      ),
      token.Token(kind: token.Dot, span: position.Span(start: 77, end: 78)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 78, end: 81),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 81, end: 84)),
      token.Token(kind: token.Dot, span: position.Span(start: 84, end: 85)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 85, end: 87),
      ),
      token.Token(kind: token.RArrow, span: position.Span(start: 87, end: 89)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 89, end: 90),
      ),
      token.Token(kind: token.Dot, span: position.Span(start: 90, end: 91)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 91, end: 94),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 94, end: 98)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 98, end: 99),
      ),
      token.Token(kind: token.Dot, span: position.Span(start: 99, end: 100)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 100, end: 103),
      ),
      token.Token(kind: token.RArrow, span: position.Span(start: 103, end: 105)),
      token.Token(kind: token.Dot, span: position.Span(start: 105, end: 106)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 106, end: 109),
      ),
      token.Token(kind: token.Space, span: position.Span(start: 109, end: 110)),
      token.Token(kind: token.RBrace, span: position.Span(start: 110, end: 111)),
      token.Token(kind: token.EOF, span: position.Span(start: 111, end: 111)),
    ]
}
