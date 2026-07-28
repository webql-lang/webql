import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_return
import webql/compiler/source

pub fn parse_returns_return_test() {
  let source = "  name:   String"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(output_return, _, rest)) = parse_return.parse(source, tokens)

  assert output_return
    == ast.Return(
      span: source.Span(start: 2, end: 16),
      name: "name",
      port: ast.Port(span: source.Span(start: 10, end: 16), name: "String"),
    )

  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 16, end: 16))]
}

pub fn parse_preserves_remaining_tokens_after_return_test() {
  let source = "name: String other"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(output_return, _, rest)) = parse_return.parse(source, tokens)

  assert output_return
    == ast.Return(
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

pub fn parse_returns_unexpected_token_for_upper_identifier_test() {
  let source = "Name: Int"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_return.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
