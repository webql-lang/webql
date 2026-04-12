import gleeunit/should
import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/cursor
import webql/lang/parser/parse_module
import webql/lang/parser/parse_operation
import webql/lang/source

pub fn parse_wraps_operation_test() {
  let source = "-> out: Int {}"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: module, rest:, ..)) =
    parse_module.parse(source, tokens)
  let assert Ok(cursor.Cursor(current: operation, ..)) =
    parse_operation.parse(source, tokens)

  should.equal(module.operation, operation)
  should.equal(module.span, operation.span)
  should.equal(rest, [
    token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14)),
  ])
}

pub fn parse_skips_leading_spaces_before_module_test() {
  let source = "  -> out: Int {}"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: module, ..)) =
    parse_module.parse(source, tokens)
  let assert Ok(cursor.Cursor(current: operation, ..)) =
    parse_operation.parse(source, tokens)

  should.equal(module.operation, operation)
  should.equal(module.span, source.Span(start: 2, end: 16))
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

  should.equal(module.operation, operation)
  should.equal(module.span, source.Span(start: 0, end: 14))
  should.equal(rest, [
    token.Token(kind: token.Space, span: source.Span(start: 14, end: 15)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 15, end: 19),
    ),
    token.Token(kind: token.EOF, span: source.Span(start: 19, end: 19)),
  ])
}
