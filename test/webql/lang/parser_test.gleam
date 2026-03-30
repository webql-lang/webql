import gleeunit/should
import webql/lang/lexer/token
import webql/lang/parser
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/source/position

pub fn parse_valid_operation_test() {
  let source = "-> out: Int {}"

  let tokens = [
    token.Token(kind: token.RArrow, span: position.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: position.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: position.Span(start: 13, end: 14)),
    token.Token(kind: token.EOF, span: position.Span(start: 14, end: 14)),
  ]

  let assert Ok(operation) = parser.parse(parser.new(source, tokens))

  should.equal(
    operation,
    ast.Operation(
      span: position.Span(start: 0, end: 14),
      inputs: [],
      outputs: [
        ast.Field(
          span: position.Span(start: 3, end: 11),
          name: "out",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      operations: [],
      expressions: [],
    ),
  )
}

pub fn parse_allows_trailing_spaces_before_eof_test() {
  let source = "-> out: Int {}   "

  let tokens = [
    token.Token(kind: token.RArrow, span: position.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: position.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: position.Span(start: 13, end: 14)),
    token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
    token.Token(kind: token.Space, span: position.Span(start: 15, end: 16)),
    token.Token(kind: token.Space, span: position.Span(start: 16, end: 17)),
    token.Token(kind: token.EOF, span: position.Span(start: 17, end: 17)),
  ]

  let assert Ok(operation) = parser.parse(parser.new(source, tokens))

  should.equal(
    operation,
    ast.Operation(
      span: position.Span(start: 0, end: 14),
      inputs: [],
      outputs: [
        ast.Field(
          span: position.Span(start: 3, end: 11),
          name: "out",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      operations: [],
      expressions: [],
    ),
  )
}

pub fn parse_errors_when_meaningful_tokens_remain_after_operation_test() {
  let source = "-> out: Int {} next"

  let tokens = [
    token.Token(kind: token.RArrow, span: position.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: position.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: position.Span(start: 13, end: 14)),
    token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 15, end: 19),
    ),
    token.Token(kind: token.EOF, span: position.Span(start: 19, end: 19)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  should.equal(
    error,
    diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: position.Span(start: 15, end: 19),
    ),
  )
}

pub fn parse_returns_unexpected_token_when_input_is_lbrace_test() {
  let source = "{"

  let tokens = [
    token.Token(kind: token.LBrace, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.EOF, span: position.Span(start: 1, end: 1)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  should.equal(
    error,
    diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LBrace),
      span: position.Span(start: 0, end: 1),
    ),
  )
}
