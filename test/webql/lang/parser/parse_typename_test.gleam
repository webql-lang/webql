import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_typename
import webql/lang/source

pub fn parse_returns_typename_test() {
  let source = " Int"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: annotation, span:, rest:)) =
    parse_typename.parse(source, tokens)

  assert annotation
    == ast.Typename(span: source.Span(start: 1, end: 4), name: "Int")
  assert span == source.Span(start: 1, end: 4)
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_preserves_remaining_tokens_after_typename_test() {
  let source = "Int String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: annotation, span:, rest:)) =
    parse_typename.parse(source, tokens)

  assert annotation
    == ast.Typename(span: source.Span(start: 0, end: 3), name: "Int")
  assert span == source.Span(start: 0, end: 3)
  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 3, end: 4)),
      token.Token(
        kind: token.UpperIdentifier,
        span: source.Span(start: 4, end: 10),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 10, end: 10)),
    ]
}

pub fn parse_returns_unexpected_eof_when_typename_is_missing_test() {
  let source = ""

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_typename.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_for_lower_identifier_test() {
  let source = "int"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_typename.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: source.Span(start: 0, end: 3),
    )
}
