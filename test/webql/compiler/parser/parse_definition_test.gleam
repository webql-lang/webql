import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/cursor
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_definition
import webql/compiler/parser/parse_operation
import webql/compiler/source

pub fn parse_definition_test() {
  let source = "Inner = -> out: Int {}"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens, parse_operation.parse)

  assert definition
    == ast.Definition(
      span: source.Span(start: 0, end: 22),
      name: "Inner",
      operation: ast.Operation(
        span: source.Span(start: 8, end: 22),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 11, end: 19),
            name: "out",
            typename: ast.Typename(
              span: source.Span(start: 16, end: 19),
              name: "Int",
            ),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 22, end: 22))]
}

pub fn parse_definition_preserves_remaining_tokens_test() {
  let source = "Inner = -> out: Int {} next"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: definition, rest:, ..)) =
    parse_definition.parse(source, tokens, parse_operation.parse)

  assert definition
    == ast.Definition(
      span: source.Span(start: 0, end: 22),
      name: "Inner",
      operation: ast.Operation(
        span: source.Span(start: 8, end: 22),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 11, end: 19),
            name: "out",
            typename: ast.Typename(
              span: source.Span(start: 16, end: 19),
              name: "Int",
            ),
          ),
        ],
        definitions: [],
        bindings: [],
        edges: [],
      ),
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 22, end: 23)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 23, end: 27),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 27, end: 27)),
    ]
}

pub fn parse_returns_unexpected_token_for_lower_identifier_definition_name_test() {
  let source = "inner = -> out: Int {}"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) =
    parse_definition.parse(source, tokens, parse_operation.parse)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LowerIdentifier),
      span: source.Span(start: 0, end: 5),
    )
}
