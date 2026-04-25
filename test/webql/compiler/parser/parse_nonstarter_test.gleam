import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

pub fn parse_consumes_leading_spaces_test() {
  let source = "   abc"
  let tokens = [
    token.Token(kind: token.Space, span: source.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: source.Span(start: 1, end: 2)),
    token.Token(kind: token.Space, span: source.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 3, end: 6),
    ),
  ]

  let assert Ok(rest) = parse_nonstarter.parse(source: source, tokens: tokens)

  assert rest
    == [
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 3, end: 6),
      ),
    ]
}

pub fn parse_consumes_leading_comments_test() {
  let source = "# comment\nabc"
  let tokens = [
    token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 0, end: 9),
    ),
    token.Token(kind: token.Space, span: source.Span(start: 9, end: 10)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 10, end: 13),
    ),
  ]

  let assert Ok(rest) = parse_nonstarter.parse(source: source, tokens: tokens)

  assert rest
    == [
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 10, end: 13),
      ),
    ]
}

pub fn parse_preserves_eof_after_spaces_test() {
  let source = "   "
  let tokens = [
    token.Token(kind: token.Space, span: source.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: source.Span(start: 1, end: 2)),
    token.Token(kind: token.Space, span: source.Span(start: 2, end: 3)),
    token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3)),
  ]

  let assert Ok(rest) = parse_nonstarter.parse(source: source, tokens: tokens)

  assert rest
    == [
      token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3)),
    ]
}

pub fn parse_returns_unexpected_token_when_first_token_is_not_space_test() {
  let source = "abc"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 0, end: 3),
    ),
  ]

  let assert Error(error) =
    parse_nonstarter.parse(source: source, tokens: tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn parse_returns_unexpected_eof_when_input_is_empty_test() {
  let source = "abc"
  let tokens = []

  let assert Error(error) =
    parse_nonstarter.parse(source: source, tokens: tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 3, end: 3),
    )
}

pub fn parse_returns_unexpected_eof_when_first_token_is_eof_test() {
  let source = "abc"
  let tokens = [
    token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3)),
  ]

  let assert Error(error) =
    parse_nonstarter.parse(source: source, tokens: tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 3, end: 3),
    )
}
