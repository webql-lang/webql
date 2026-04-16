import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/parse_output
import webql/lang/source

pub fn parse_returns_output_test() {
  let source = "  name:   String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: output, rest:, ..)) =
    parse_output.parse(source, tokens)

  assert output
    == ast.Output(
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
