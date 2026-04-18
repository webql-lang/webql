import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_binding
import webql/lang/source

pub fn parse_binding_definition_test() {
  let source = "m = Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: binding, rest:, ..)) =
    parse_binding.parse(source, tokens)

  assert binding
    == ast.Binding(
      span: source.Span(start: 0, end: 8),
      name: "m",
      value: ast.NodeValue(name: "Math", span: source.Span(start: 4, end: 8)),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 8, end: 8))]
}

pub fn parse_binding_primitive_value_test() {
  let source = "count = 123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: binding, rest:, ..)) =
    parse_binding.parse(source, tokens)

  assert binding
    == ast.Binding(
      span: source.Span(start: 0, end: 11),
      name: "count",
      value: ast.PrimitiveValue(
        span: source.Span(start: 8, end: 11),
        value: ast.Int(span: source.Span(start: 8, end: 11), value: 123),
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 11, end: 11))]
}

pub fn parse_preserves_remaining_tokens_after_binding_test() {
  let source = "m = Math next"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: binding, rest:, ..)) =
    parse_binding.parse(source, tokens)

  assert binding
    == ast.Binding(
      span: source.Span(start: 0, end: 8),
      name: "m",
      value: ast.NodeValue(name: "Math", span: source.Span(start: 4, end: 8)),
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 8, end: 9)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 9, end: 13),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 13, end: 13)),
    ]
}

pub fn parse_returns_unexpected_token_for_upper_identifier_binding_name_test() {
  let source = "Math = Text"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_binding.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}

pub fn parse_returns_unexpected_eof_when_binding_value_is_missing_test() {
  let source = "m = "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_binding.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 4, end: 4),
    )
}
