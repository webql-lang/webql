import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_value
import webql/compiler/source

pub fn parse_node_value_test() {
  let source = "Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert span == source.Span(start: 0, end: 4)
  assert value
    == ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_returns_unexpected_token_for_primitive_value_test() {
  let source = "123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_value.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Int),
      span: source.Span(start: 0, end: 3),
    )
}

pub fn parse_preserves_remaining_tokens_after_node_value_test() {
  let source = "Math next"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(value, span, rest)) = parse_value.parse(source, tokens)

  assert span == source.Span(start: 0, end: 4)
  assert value
    == ast.NodeValue(name: "Math", span: source.Span(start: 0, end: 4))
  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 4, end: 5)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 5, end: 9),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 9, end: 9)),
    ]
}

pub fn parse_returns_unexpected_token_for_invalid_value_start_test() {
  let source = "math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_value.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
