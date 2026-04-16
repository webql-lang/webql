import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_reference
import webql/lang/source

pub fn parse_node_port_reference_test() {
  let source = "m.out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: reference, span:, rest:)) =
    parse_reference.parse(source, tokens)

  assert span == source.Span(start: 0, end: 5)
  assert reference
    == ast.OutputAccess(span: source.Span(start: 0, end: 5), path: ["m", "out"])
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 5, end: 5))]
}

pub fn parse_operation_port_reference_test() {
  let source = ".out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: reference, span:, rest:)) =
    parse_reference.parse(source, tokens)

  assert span == source.Span(start: 0, end: 4)
  assert reference
    == ast.InputAccess(span: source.Span(start: 0, end: 4), path: ["out"])
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_literal_reference_test() {
  let source = "123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: reference, span:, rest:)) =
    parse_reference.parse(source, tokens)

  assert span == source.Span(start: 0, end: 3)
  assert reference
    == ast.Literal(
      span: source.Span(start: 0, end: 3),
      value: ast.Int(span: source.Span(start: 0, end: 3), value: 123),
    )
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3))]
}

pub fn parse_preserves_remaining_tokens_after_reference_test() {
  let source = "m.out next"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: reference, span:, rest:)) =
    parse_reference.parse(source, tokens)

  assert span == source.Span(start: 0, end: 5)
  assert reference
    == ast.OutputAccess(span: source.Span(start: 0, end: 5), path: ["m", "out"])
  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 5, end: 6)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 6, end: 10),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 10, end: 10)),
    ]
}

pub fn parse_returns_error_when_space_exists_between_node_alias_and_dot_test() {
  let source = "m .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_reference.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: source.Span(start: 1, end: 2),
    )
}

pub fn parse_returns_unexpected_eof_when_operation_port_name_is_missing_test() {
  let source = "."

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_reference.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.EOF),
      span: source.Span(start: 1, end: 1),
    )
}

pub fn parse_returns_unexpected_token_for_invalid_reference_start_test() {
  let source = "Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_reference.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
