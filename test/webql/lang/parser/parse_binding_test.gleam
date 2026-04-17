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
      value: ast.Node(name: "Math", span: source.Span(start: 4, end: 8)),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 8, end: 8))]
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
