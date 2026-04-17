import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_operation
import webql/lang/source

pub fn parse_parses_operation_with_nested_operation_and_definition_test() {
  let source =
    "a: Int, b: String -> c: Float, d: Bool { Inner = x: Int -> y: Int {} .a -> .c }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: operation, rest:, ..)) =
    parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 79),
      inputs: [
        ast.Input(
          span: source.Span(start: 0, end: 6),
          name: "a",
          typename: ast.Typename(
            span: source.Span(start: 3, end: 6),
            name: "Int",
          ),
        ),
        ast.Input(
          span: source.Span(start: 8, end: 17),
          name: "b",
          typename: ast.Typename(
            span: source.Span(start: 11, end: 17),
            name: "String",
          ),
        ),
      ],
      outputs: [
        ast.Output(
          span: source.Span(start: 21, end: 29),
          name: "c",
          typename: ast.Typename(
            span: source.Span(start: 24, end: 29),
            name: "Float",
          ),
        ),
        ast.Output(
          span: source.Span(start: 31, end: 38),
          name: "d",
          typename: ast.Typename(
            span: source.Span(start: 34, end: 38),
            name: "Bool",
          ),
        ),
      ],
      bindings: [
        ast.Binding(
          span: source.Span(start: 41, end: 68),
          name: "Inner",
          value: ast.SubOperation(
            name: "Inner",
            span: source.Span(start: 49, end: 68),
            operation: ast.Operation(
              span: source.Span(start: 49, end: 68),
              inputs: [
                ast.Input(
                  span: source.Span(start: 49, end: 55),
                  name: "x",
                  typename: ast.Typename(
                    span: source.Span(start: 52, end: 55),
                    name: "Int",
                  ),
                ),
              ],
              outputs: [
                ast.Output(
                  span: source.Span(start: 59, end: 65),
                  name: "y",
                  typename: ast.Typename(
                    span: source.Span(start: 62, end: 65),
                    name: "Int",
                  ),
                ),
              ],
              bindings: [],
              edges: [],
            ),
          ),
        ),
      ],
      edges: [
        ast.Edge(
          span: source.Span(start: 69, end: 77),
          from: ast.InputAccess(span: source.Span(start: 69, end: 71), path: [
            "a",
          ]),
          to: ast.InputAccess(span: source.Span(start: 75, end: 77), path: ["c"]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 79, end: 79))]
}

pub fn parse_preserves_remaining_tokens_after_operation_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: operation, rest:, ..)) =
    parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 14),
      inputs: [],
      outputs: [
        ast.Output(
          span: source.Span(start: 3, end: 11),
          name: "out",
          typename: ast.Typename(
            span: source.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      bindings: [],
      edges: [],
    )

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

pub fn parse_returns_unexpected_token_for_invalid_operation_start_test() {
  let source = "{"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_operation.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_operation_body_is_unterminated_test() {
  let source = "-> out: Int {"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_operation.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 13, end: 13),
    )
}
