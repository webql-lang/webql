import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/source

pub fn parse_allows_comments_before_inside_and_after_document_test() {
  let source = "# document\n-> out: Int { # body\n}"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(document) = parser.parse(parser.new(source, tokens))

  assert document
    == ast.Document(
      span: source.Span(start: 11, end: 33),
      graph: ast.Graph(
        span: source.Span(start: 11, end: 33),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 14, end: 22),
            name: "out",
            port: ast.Port(span: source.Span(start: 19, end: 22), name: "Int"),
          ),
        ],
        nodes: [],
        edges: [],
      ),
    )
}

pub fn parse_allows_trailing_spaces_before_eof_test() {
  let source = "-> out: Int {}   "

  let tokens = [
    lexer.Token(kind: lexer.RArrow, span: source.Span(start: 0, end: 2)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 2, end: 3)),
    lexer.Token(
      kind: lexer.LowerIdentifier,
      span: source.Span(start: 3, end: 6),
    ),
    lexer.Token(kind: lexer.Colon, span: source.Span(start: 6, end: 7)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 7, end: 8)),
    lexer.Token(
      kind: lexer.UpperIdentifier,
      span: source.Span(start: 8, end: 11),
    ),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 11, end: 12)),
    lexer.Token(kind: lexer.LBrace, span: source.Span(start: 12, end: 13)),
    lexer.Token(kind: lexer.RBrace, span: source.Span(start: 13, end: 14)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 15, end: 16)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 16, end: 17)),
    lexer.Token(kind: lexer.EOF, span: source.Span(start: 17, end: 17)),
  ]

  let assert Ok(document) = parser.parse(parser.new(source, tokens))

  assert document
    == ast.Document(
      span: source.Span(start: 0, end: 14),
      graph: ast.Graph(
        span: source.Span(start: 0, end: 14),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 3, end: 11),
            name: "out",
            port: ast.Port(span: source.Span(start: 8, end: 11), name: "Int"),
          ),
        ],
        nodes: [],
        edges: [],
      ),
    )
}

pub fn parse_errors_when_meaningful_tokens_remain_after_document_test() {
  let source = "-> out: Int {} next"

  let tokens = [
    lexer.Token(kind: lexer.RArrow, span: source.Span(start: 0, end: 2)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 2, end: 3)),
    lexer.Token(
      kind: lexer.LowerIdentifier,
      span: source.Span(start: 3, end: 6),
    ),
    lexer.Token(kind: lexer.Colon, span: source.Span(start: 6, end: 7)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 7, end: 8)),
    lexer.Token(
      kind: lexer.UpperIdentifier,
      span: source.Span(start: 8, end: 11),
    ),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 11, end: 12)),
    lexer.Token(kind: lexer.LBrace, span: source.Span(start: 12, end: 13)),
    lexer.Token(kind: lexer.RBrace, span: source.Span(start: 13, end: 14)),
    lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
    lexer.Token(
      kind: lexer.LowerIdentifier,
      span: source.Span(start: 15, end: 19),
    ),
    lexer.Token(kind: lexer.EOF, span: source.Span(start: 19, end: 19)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.LowerIdentifier),
      span: source.Span(start: 15, end: 19),
    )
}

pub fn parse_returns_unexpected_token_when_input_is_lbrace_test() {
  let source = "{"

  let tokens = [
    lexer.Token(kind: lexer.LBrace, span: source.Span(start: 0, end: 1)),
    lexer.Token(kind: lexer.EOF, span: source.Span(start: 1, end: 1)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_input_is_empty_test() {
  let source = ""

  let tokens = [
    lexer.Token(kind: lexer.EOF, span: source.Span(start: 0, end: 0)),
  ]

  let assert Error(error) = parser.parse(parser.new(source, tokens))

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}
