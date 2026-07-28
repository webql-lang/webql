import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_port
import webql/compiler/source

pub fn parse_returns_port_test() {
  let source = " Int"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(annotation, span, rest)) = parse_port.parse(source, tokens)

  assert annotation
    == ast.Port(span: source.Span(start: 1, end: 4), name: "Int")
  assert span == source.Span(start: 1, end: 4)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_preserves_remaining_tokens_after_port_test() {
  let source = "Int String"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(annotation, span, rest)) = parse_port.parse(source, tokens)

  assert annotation
    == ast.Port(span: source.Span(start: 0, end: 3), name: "Int")
  assert span == source.Span(start: 0, end: 3)
  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 3, end: 4)),
      lexer.Token(
        kind: lexer.UpperIdentifier,
        span: source.Span(start: 4, end: 10),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 10, end: 10)),
    ]
}

pub fn parse_returns_unexpected_eof_when_port_is_missing_test() {
  let source = ""

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_port.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_for_lower_identifier_test() {
  let source = "int"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_port.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.LowerIdentifier),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn parse_accepts_upper_identifier_with_digits_test() {
  let source = "Int32"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(annotation, span, rest)) = parse_port.parse(source, tokens)

  assert annotation
    == ast.Port(span: source.Span(start: 0, end: 5), name: "Int32")
  assert span == source.Span(start: 0, end: 5)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 5, end: 5))]
}
