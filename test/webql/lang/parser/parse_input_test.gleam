import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_input
import webql/lang/source

pub fn parse_returns_input_test() {
  let source = "  name:   String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: input, rest:, ..)) =
    parse_input.parse(source, tokens)

  assert input
    == ast.Input(
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

pub fn parse_preserves_remaining_tokens_after_input_test() {
  let source = "name: String other"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: input, rest:, ..)) =
    parse_input.parse(source, tokens)

  assert input
    == ast.Input(
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

pub fn parse_returns_unexpected_eof_when_tokens_are_empty_test() {
  let source = ""

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_input.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_when_separator_is_missing_test() {
  let source = "name String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_input.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: source.Span(start: 4, end: 5),
    )
}

pub fn parse_returns_unexpected_eof_when_annotation_is_missing_test() {
  let source = "name: "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_input.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 6, end: 6),
    )
}
