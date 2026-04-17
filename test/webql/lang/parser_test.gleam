import webql/lang/lexer/token
import webql/lang/parser
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/source

pub fn parse_allows_trailing_spaces_before_eof_test() {
  let source = "-> out: Int {}   "

  let tokens = [
    token.Token(kind: token.RArrow, span: source.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: source.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: source.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: source.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: source.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: source.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: source.Span(start: 13, end: 14)),
    token.Token(kind: token.Space, span: source.Span(start: 14, end: 15)),
    token.Token(kind: token.Space, span: source.Span(start: 15, end: 16)),
    token.Token(kind: token.Space, span: source.Span(start: 16, end: 17)),
    token.Token(kind: token.EOF, span: source.Span(start: 17, end: 17)),
  ]

  let assert Ok(module) = parser.parse(parser.new(source, tokens))

  assert module
    == ast.Module(
      span: source.Span(start: 0, end: 14),
      operation: ast.Operation(
        span: source.Span(start: 0, end: 14),
        inputs: [],
        outputs: [
          ast.Output(
            span: source.Span(start: 3, end: 11),
            name: "out",
            typename: ast.Typename(
              span: source.Span(start: 8, end: 11),
              name: "Int",
            ),
          ),
        ],
        bindings: [],
        edges: [],
      ),
    )
}

pub fn parse_errors_when_meaningful_tokens_remain_after_module_test() {
  let source = "-> out: Int {} next"

  let tokens = [
    token.Token(kind: token.RArrow, span: source.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: source.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: source.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: source.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: source.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: source.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: source.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: source.Span(start: 13, end: 14)),
    token.Token(kind: token.Space, span: source.Span(start: 14, end: 15)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 15, end: 19),
    ),
    token.Token(kind: token.EOF, span: source.Span(start: 19, end: 19)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: source.Span(start: 15, end: 19),
    )
}

pub fn parse_returns_unexpected_token_when_input_is_lbrace_test() {
  let source = "{"

  let tokens = [
    token.Token(kind: token.LBrace, span: source.Span(start: 0, end: 1)),
    token.Token(kind: token.EOF, span: source.Span(start: 1, end: 1)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_input_is_empty_test() {
  let source = ""

  let tokens = [
    token.Token(kind: token.EOF, span: source.Span(start: 0, end: 0)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}
