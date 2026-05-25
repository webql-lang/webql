import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_return
import webql/compiler/source

pub fn parse_returns_return_test() {
  let source = "  name:   String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(output_return, _, rest)) = parse_return.parse(source, tokens)

  assert output_return
    == ast.Return(
      span: source.Span(start: 2, end: 16),
      name: "name",
      typename: ast.Typename(
        span: source.Span(start: 10, end: 16),
        name: "String",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 16, end: 16))]
}

pub fn parse_preserves_remaining_tokens_after_return_test() {
  let source = "name: String other"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(output_return, _, rest)) = parse_return.parse(source, tokens)

  assert output_return
    == ast.Return(
      span: source.Span(start: 0, end: 12),
      name: "name",
      typename: ast.Typename(
        span: source.Span(start: 6, end: 12),
        name: "String",
      ),
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 12, end: 13)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 13, end: 18),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 18, end: 18)),
    ]
}

pub fn parse_returns_unexpected_token_for_upper_identifier_test() {
  let source = "Name: Int"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_return.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
