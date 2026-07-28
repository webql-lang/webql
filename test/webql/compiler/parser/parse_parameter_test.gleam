import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_parameter
import webql/compiler/source

pub fn parse_returns_parameter_test() {
  let source = "  name:   String"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(parameter, _, rest)) = parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 2, end: 16),
      name: "name",
      port: ast.Port(span: source.Span(start: 10, end: 16), name: "String"),
    )

  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 16, end: 16))]
}

pub fn parse_preserves_remaining_tokens_after_parameter_test() {
  let source = "name: String other"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(parameter, _, rest)) = parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 0, end: 12),
      name: "name",
      port: ast.Port(span: source.Span(start: 6, end: 12), name: "String"),
    )

  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 12, end: 13)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 13, end: 18),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 18, end: 18)),
    ]
}

pub fn parse_returns_unexpected_eof_when_tokens_are_empty_test() {
  let source = ""

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_parameter.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_when_separator_is_missing_test() {
  let source = "name String"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_parameter.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.Whitespace),
      span: source.Span(start: 4, end: 5),
    )
}

pub fn parse_returns_unexpected_eof_when_annotation_is_missing_test() {
  let source = "name: "

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_parameter.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 6, end: 6),
    )
}

pub fn parse_returns_unexpected_token_for_upper_identifier_test() {
  let source = "Name: Int"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_parameter.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
