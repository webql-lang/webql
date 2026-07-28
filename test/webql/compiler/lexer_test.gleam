import webql/compiler/lexer
import webql/compiler/source

pub fn run_lexer_on_empty_input_test() {
  let assert Ok(tokens) = lexer.tokenize("")

  assert tokens
    == [
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 0, end: 0)),
    ]
}

pub fn run_lexer_on_a_single_integer_test() {
  let assert Ok(tokens) = lexer.tokenize("123")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_single_float_test() {
  let assert Ok(tokens) = lexer.tokenize("1.23")

  assert tokens
    == [
      lexer.Token(kind: lexer.Float, span: source.Span(start: 0, end: 4)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4)),
    ]
}

pub fn run_lexer_on_a_single_string_test() {
  let assert Ok(tokens) = lexer.tokenize("\"hello world\"")

  assert tokens
    == [
      lexer.Token(kind: lexer.String, span: source.Span(start: 0, end: 13)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 13, end: 13)),
    ]
}

pub fn run_lexer_on_the_full_symbol_set_test() {
  let assert Ok(tokens) = lexer.tokenize("(){}[]:,=->.")

  assert tokens
    == [
      lexer.Token(kind: lexer.LParen, span: source.Span(start: 0, end: 1)),
      lexer.Token(kind: lexer.RParen, span: source.Span(start: 1, end: 2)),
      lexer.Token(kind: lexer.LBrace, span: source.Span(start: 2, end: 3)),
      lexer.Token(kind: lexer.RBrace, span: source.Span(start: 3, end: 4)),
      lexer.Token(kind: lexer.LSquare, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.RSquare, span: source.Span(start: 5, end: 6)),
      lexer.Token(kind: lexer.Colon, span: source.Span(start: 6, end: 7)),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 7, end: 8)),
      lexer.Token(kind: lexer.Equal, span: source.Span(start: 8, end: 9)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 9, end: 11)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 11, end: 12)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 12, end: 12)),
    ]
}

pub fn run_lexer_on_a_single_comment_test() {
  let assert Ok(tokens) = lexer.tokenize("# hello")

  assert tokens
    == [
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 0, end: 7)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 7, end: 7)),
    ]
}

pub fn run_lexer_on_a_single_whitespace_test() {
  let assert Ok(tokens) = lexer.tokenize(" \t\n")

  assert tokens
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 0, end: 3)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_mixed_stream_test() {
  let assert Ok(tokens) = lexer.tokenize("(123) -> \"hi\", # ok\n[]")

  assert tokens
    == [
      lexer.Token(kind: lexer.LParen, span: source.Span(start: 0, end: 1)),
      lexer.Token(kind: lexer.Int, span: source.Span(start: 1, end: 4)),
      lexer.Token(kind: lexer.RParen, span: source.Span(start: 4, end: 5)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 5, end: 6)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 6, end: 8)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 8, end: 9)),
      lexer.Token(kind: lexer.String, span: source.Span(start: 9, end: 13)),
      lexer.Token(kind: lexer.Comma, span: source.Span(start: 13, end: 14)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
      lexer.Token(kind: lexer.Comment, span: source.Span(start: 15, end: 19)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 19, end: 20)),
      lexer.Token(kind: lexer.LSquare, span: source.Span(start: 20, end: 21)),
      lexer.Token(kind: lexer.RSquare, span: source.Span(start: 21, end: 22)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 22, end: 22)),
    ]
}

pub fn run_lexer_on_a_single_upper_identifier_test() {
  let assert Ok(tokens) = lexer.tokenize("Abc")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 0, end: 3),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 3, end: 3)),
    ]
}

pub fn run_lexer_on_a_single_lower_identifier_test() {
  let assert Ok(tokens) = lexer.tokenize("abc_2")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 0, end: 5),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 5, end: 5)),
    ]
}

pub fn run_lexer_fails_on_invalid_symbol_test() {
  let assert Error(lexer.Diagnostic(
    kind: lexer.IllegalToken,
    span: source.Span(start: 0, end: 1),
  )) = lexer.tokenize("!")
}

pub fn run_lexer_fails_on_invalid_symbol_after_valid_tokens_test() {
  let assert Error(lexer.Diagnostic(
    kind: lexer.IllegalToken,
    span: source.Span(start: 3, end: 4),
  )) = lexer.tokenize("123!")
}

pub fn run_lexer_recovers_on_invalid_symbol_test() {
  let tokens = lexer.tokenize_recovering("!")

  assert tokens
    == [
      lexer.Token(
        kind: lexer.Invalid(lexer.IllegalToken),
        span: source.Span(start: 0, end: 1),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 1, end: 1)),
    ]
}

pub fn run_lexer_recovers_on_invalid_symbol_after_valid_tokens_test() {
  let tokens = lexer.tokenize_recovering("123!")

  assert tokens
    == [
      lexer.Token(kind: lexer.Int, span: source.Span(start: 0, end: 3)),
      lexer.Token(
        kind: lexer.Invalid(lexer.IllegalToken),
        span: source.Span(start: 3, end: 4),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4)),
    ]
}

pub fn run_lexer_on_basic_syntax_test() {
  let source =
    "Addition = in: Int -> out: Int {
  m = Math

  \"addition\"->m.graph
  1->m.lhs
  .in->m.rhs

  m.out->.out
}"

  let assert Ok(tokens) = lexer.tokenize(source)

  assert tokens
    == [
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 0, end: 8),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 8, end: 9)),
      lexer.Token(kind: lexer.Equal, span: source.Span(start: 9, end: 10)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 10, end: 11)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 11, end: 13),
      ),
      lexer.Token(kind: lexer.Colon, span: source.Span(start: 13, end: 14)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 15, end: 18),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 18, end: 19)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 19, end: 21)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 21, end: 22)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 22, end: 25),
      ),
      lexer.Token(kind: lexer.Colon, span: source.Span(start: 25, end: 26)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 26, end: 27)),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 27, end: 30),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 30, end: 31)),
      lexer.Token(kind: lexer.LBrace, span: source.Span(start: 31, end: 32)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 32, end: 35)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 35, end: 36),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 36, end: 37)),
      lexer.Token(kind: lexer.Equal, span: source.Span(start: 37, end: 38)),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 38, end: 39)),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 39, end: 43),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 43, end: 47)),
      lexer.Token(kind: lexer.String, span: source.Span(start: 47, end: 57)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 57, end: 59)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 59, end: 60),
      ),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 60, end: 61)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 61, end: 66),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 66, end: 69)),
      lexer.Token(kind: lexer.Int, span: source.Span(start: 69, end: 70)),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 70, end: 72)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 72, end: 73),
      ),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 73, end: 74)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 74, end: 77),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 77, end: 80)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 80, end: 81)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 81, end: 83),
      ),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 83, end: 85)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 85, end: 86),
      ),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 86, end: 87)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 87, end: 90),
      ),
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 90, end: 94)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 94, end: 95),
      ),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 95, end: 96)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 96, end: 99),
      ),
      lexer.Token(kind: lexer.RArrow, span: source.Span(start: 99, end: 101)),
      lexer.Token(kind: lexer.Dot, span: source.Span(start: 101, end: 102)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 102, end: 105),
      ),
      lexer.Token(
        kind: lexer.Whitespace,
        span: source.Span(start: 105, end: 106),
      ),
      lexer.Token(kind: lexer.RBrace, span: source.Span(start: 106, end: 107)),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 107, end: 107)),
    ]
}
