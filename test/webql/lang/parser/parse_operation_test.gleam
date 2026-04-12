import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_operation
import webql/lang/source

pub fn parse_parses_operation_with_nested_operation_and_expression_test() {
  let source =
    "a: Int, b: String -> c: Float, d: Bool { Inner = x: Int -> y: Int {} .a -> .c }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: operation, tokens: rest, ..)) =
    parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 79),
      inputs: [
        ast.Parameter(
          span: source.Span(start: 0, end: 6),
          name: "a",
          typename: ast.Typename(
            span: source.Span(start: 3, end: 6),
            name: "Int",
          ),
        ),
        ast.Parameter(
          span: source.Span(start: 8, end: 17),
          name: "b",
          typename: ast.Typename(
            span: source.Span(start: 11, end: 17),
            name: "String",
          ),
        ),
      ],
      outputs: [
        ast.Parameter(
          span: source.Span(start: 21, end: 29),
          name: "c",
          typename: ast.Typename(
            span: source.Span(start: 24, end: 29),
            name: "Float",
          ),
        ),
        ast.Parameter(
          span: source.Span(start: 31, end: 38),
          name: "d",
          typename: ast.Typename(
            span: source.Span(start: 34, end: 38),
            name: "Bool",
          ),
        ),
      ],
      operations: [],
      expressions: [
        ast.Binding(
          span: source.Span(start: 41, end: 68),
          name: "Inner",
          value: ast.SubOperation(
            span: source.Span(start: 41, end: 68),
            inputs: [
              ast.Parameter(
                span: source.Span(start: 49, end: 55),
                name: "x",
                typename: ast.Typename(
                  span: source.Span(start: 52, end: 55),
                  name: "Int",
                ),
              ),
            ],
            outputs: [
              ast.Parameter(
                span: source.Span(start: 59, end: 65),
                name: "y",
                typename: ast.Typename(
                  span: source.Span(start: 62, end: 65),
                  name: "Int",
                ),
              ),
            ],
            operations: [],
            expressions: [],
          ),
        ),
        ast.Edge(
          span: source.Span(start: 69, end: 77),
          from: ast.Access(span: source.Span(start: 69, end: 71), path: ["a"]),
          to: ast.Access(span: source.Span(start: 75, end: 77), path: ["c"]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 79, end: 79))]
}

pub fn parse_skips_spaces_throughout_operation_test() {
  let source =
    "  a: Int , b: String   ->   c: Float , d: Bool {   Inner   =   x: Int -> y: Int { }   .a   ->   .c   }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: operation, tokens: rest, ..)) =
    parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 2, end: 102),
      inputs: [
        ast.Parameter(
          span: source.Span(start: 2, end: 8),
          name: "a",
          typename: ast.Typename(
            span: source.Span(start: 5, end: 8),
            name: "Int",
          ),
        ),
        ast.Parameter(
          span: source.Span(start: 11, end: 20),
          name: "b",
          typename: ast.Typename(
            span: source.Span(start: 14, end: 20),
            name: "String",
          ),
        ),
      ],
      outputs: [
        ast.Parameter(
          span: source.Span(start: 28, end: 36),
          name: "c",
          typename: ast.Typename(
            span: source.Span(start: 31, end: 36),
            name: "Float",
          ),
        ),
        ast.Parameter(
          span: source.Span(start: 39, end: 46),
          name: "d",
          typename: ast.Typename(
            span: source.Span(start: 42, end: 46),
            name: "Bool",
          ),
        ),
      ],
      operations: [],
      expressions: [
        ast.Binding(
          span: source.Span(start: 51, end: 83),
          name: "Inner",
          value: ast.SubOperation(
            span: source.Span(start: 51, end: 83),
            inputs: [
              ast.Parameter(
                span: source.Span(start: 63, end: 69),
                name: "x",
                typename: ast.Typename(
                  span: source.Span(start: 66, end: 69),
                  name: "Int",
                ),
              ),
            ],
            outputs: [
              ast.Parameter(
                span: source.Span(start: 73, end: 79),
                name: "y",
                typename: ast.Typename(
                  span: source.Span(start: 76, end: 79),
                  name: "Int",
                ),
              ),
            ],
            operations: [],
            expressions: [],
          ),
        ),
        ast.Edge(
          span: source.Span(start: 86, end: 98),
          from: ast.Access(span: source.Span(start: 86, end: 88), path: ["a"]),
          to: ast.Access(span: source.Span(start: 96, end: 98), path: ["c"]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 102, end: 102))]
}

pub fn parse_preserves_remaining_tokens_after_operation_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: operation, tokens: rest, ..)) =
    parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 14),
      inputs: [],
      outputs: [
        ast.Parameter(
          span: source.Span(start: 3, end: 11),
          name: "out",
          typename: ast.Typename(
            span: source.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      operations: [],
      expressions: [],
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
