import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/cursor
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_module
import webql/compiler/parser/parse_operation
import webql/compiler/source

pub fn parse_wraps_operation_test() {
  let source = "  -> out: Int {}"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: module, rest:, ..)) =
    parse_module.parse(source, tokens)
  let assert Ok(cursor.Cursor(current: operation, ..)) =
    parse_operation.parse(source, tokens)

  assert module.operation == operation
  assert module.span == source.Span(start: 2, end: 16)
  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 16, end: 16))]
}

pub fn parse_preserves_remaining_tokens_after_module_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: module, rest:, ..)) =
    parse_module.parse(source, tokens)
  let assert Ok(cursor.Cursor(current: operation, ..)) =
    parse_operation.parse(source, tokens)

  assert module.operation == operation
  assert module.span == source.Span(start: 0, end: 14)
  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 14, end: 15)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 15, end: 19),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 19, end: 19)),
    ]
}

pub fn parse_returns_unexpected_token_for_invalid_module_start_test() {
  let source = "{"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_module.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}
