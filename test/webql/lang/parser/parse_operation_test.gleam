import gleam/list
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_operation
import webql/lang/source/position

pub fn parse_parses_operation_with_nested_operation_and_expression_test() {
  let source =
    "a: Int, b: String -> c: Float, d: Bool { Inner = x: Int -> y: Int {} .a -> .c }"

  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.Space, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Comma, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 8, end: 9),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 9, end: 10)),
    token.Token(kind: token.Space, span: position.Span(start: 10, end: 11)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 11, end: 17),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 17, end: 18)),
    token.Token(kind: token.RArrow, span: position.Span(start: 18, end: 20)),
    token.Token(kind: token.Space, span: position.Span(start: 20, end: 21)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 21, end: 22),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 22, end: 23)),
    token.Token(kind: token.Space, span: position.Span(start: 23, end: 24)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 24, end: 29),
    ),
    token.Token(kind: token.Comma, span: position.Span(start: 29, end: 30)),
    token.Token(kind: token.Space, span: position.Span(start: 30, end: 31)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 31, end: 32),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 32, end: 33)),
    token.Token(kind: token.Space, span: position.Span(start: 33, end: 34)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 34, end: 38),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 38, end: 39)),
    token.Token(kind: token.LBrace, span: position.Span(start: 39, end: 40)),
    token.Token(kind: token.Space, span: position.Span(start: 40, end: 41)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 41, end: 46),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 46, end: 47)),
    token.Token(kind: token.Equal, span: position.Span(start: 47, end: 48)),
    token.Token(kind: token.Space, span: position.Span(start: 48, end: 49)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 49, end: 50),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 50, end: 51)),
    token.Token(kind: token.Space, span: position.Span(start: 51, end: 52)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 52, end: 55),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 55, end: 56)),
    token.Token(kind: token.RArrow, span: position.Span(start: 56, end: 58)),
    token.Token(kind: token.Space, span: position.Span(start: 58, end: 59)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 59, end: 60),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 60, end: 61)),
    token.Token(kind: token.Space, span: position.Span(start: 61, end: 62)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 62, end: 65),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 65, end: 66)),
    token.Token(kind: token.LBrace, span: position.Span(start: 66, end: 67)),
    token.Token(kind: token.RBrace, span: position.Span(start: 67, end: 68)),
    token.Token(kind: token.Space, span: position.Span(start: 68, end: 69)),
    token.Token(kind: token.Dot, span: position.Span(start: 69, end: 70)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 70, end: 71),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 71, end: 72)),
    token.Token(kind: token.RArrow, span: position.Span(start: 72, end: 74)),
    token.Token(kind: token.Space, span: position.Span(start: 74, end: 75)),
    token.Token(kind: token.Dot, span: position.Span(start: 75, end: 76)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 76, end: 77),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 77, end: 78)),
    token.Token(kind: token.RBrace, span: position.Span(start: 78, end: 79)),
  ]

  let assert Ok(#(operation, rest)) = parse_operation.parse(source, tokens)

  case operation {
    ast.Operation(inputs:, outputs:, operations:, expressions:) -> {
      assert inputs
        == [
          ast.Field(name: "a", annotation: ast.NamedTypeAnnotation("Int")),
          ast.Field(name: "b", annotation: ast.NamedTypeAnnotation("String")),
        ]

      assert outputs
        == [
          ast.Field(name: "c", annotation: ast.NamedTypeAnnotation("Float")),
          ast.Field(name: "d", annotation: ast.NamedTypeAnnotation("Bool")),
        ]

      assert operations
        == [
          ast.NestedOperation(
            name: "Inner",
            inputs: [
              ast.Field(name: "x", annotation: ast.NamedTypeAnnotation("Int")),
            ],
            outputs: [
              ast.Field(name: "y", annotation: ast.NamedTypeAnnotation("Int")),
            ],
            operations: [],
            expressions: [],
          ),
        ]

      assert list.length(expressions) == 1
      assert rest == []
    }

    _ -> panic
  }
}

pub fn parse_skips_spaces_throughout_operation_test() {
  let source =
    "  a: Int , b: String   ->   c: Float , d: Bool {   Inner   =   x: Int -> y: Int { }   .a   ->   .c   }"

  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 3),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 3, end: 4)),
    token.Token(kind: token.Space, span: position.Span(start: 4, end: 5)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 5, end: 8),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
    token.Token(kind: token.Comma, span: position.Span(start: 9, end: 10)),
    token.Token(kind: token.Space, span: position.Span(start: 10, end: 11)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 11, end: 12),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 12, end: 13)),
    token.Token(kind: token.Space, span: position.Span(start: 13, end: 14)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 14, end: 20),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 20, end: 21)),
    token.Token(kind: token.Space, span: position.Span(start: 21, end: 22)),
    token.Token(kind: token.Space, span: position.Span(start: 22, end: 23)),
    token.Token(kind: token.RArrow, span: position.Span(start: 23, end: 25)),
    token.Token(kind: token.Space, span: position.Span(start: 25, end: 26)),
    token.Token(kind: token.Space, span: position.Span(start: 26, end: 27)),
    token.Token(kind: token.Space, span: position.Span(start: 27, end: 28)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 28, end: 29),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 29, end: 30)),
    token.Token(kind: token.Space, span: position.Span(start: 30, end: 31)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 31, end: 36),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 36, end: 37)),
    token.Token(kind: token.Comma, span: position.Span(start: 37, end: 38)),
    token.Token(kind: token.Space, span: position.Span(start: 38, end: 39)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 39, end: 40),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 40, end: 41)),
    token.Token(kind: token.Space, span: position.Span(start: 41, end: 42)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 42, end: 46),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 46, end: 47)),
    token.Token(kind: token.LBrace, span: position.Span(start: 47, end: 48)),
    token.Token(kind: token.Space, span: position.Span(start: 48, end: 49)),
    token.Token(kind: token.Space, span: position.Span(start: 49, end: 50)),
    token.Token(kind: token.Space, span: position.Span(start: 50, end: 51)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 51, end: 56),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 56, end: 57)),
    token.Token(kind: token.Space, span: position.Span(start: 57, end: 58)),
    token.Token(kind: token.Space, span: position.Span(start: 58, end: 59)),
    token.Token(kind: token.Equal, span: position.Span(start: 59, end: 60)),
    token.Token(kind: token.Space, span: position.Span(start: 60, end: 61)),
    token.Token(kind: token.Space, span: position.Span(start: 61, end: 62)),
    token.Token(kind: token.Space, span: position.Span(start: 62, end: 63)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 63, end: 64),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 64, end: 65)),
    token.Token(kind: token.Space, span: position.Span(start: 65, end: 66)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 66, end: 69),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 69, end: 70)),
    token.Token(kind: token.RArrow, span: position.Span(start: 70, end: 72)),
    token.Token(kind: token.Space, span: position.Span(start: 72, end: 73)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 73, end: 74),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 74, end: 75)),
    token.Token(kind: token.Space, span: position.Span(start: 75, end: 76)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 76, end: 79),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 79, end: 80)),
    token.Token(kind: token.LBrace, span: position.Span(start: 80, end: 81)),
    token.Token(kind: token.Space, span: position.Span(start: 81, end: 82)),
    token.Token(kind: token.RBrace, span: position.Span(start: 82, end: 83)),
    token.Token(kind: token.Space, span: position.Span(start: 83, end: 84)),
    token.Token(kind: token.Space, span: position.Span(start: 84, end: 85)),
    token.Token(kind: token.Space, span: position.Span(start: 85, end: 86)),
    token.Token(kind: token.Dot, span: position.Span(start: 86, end: 87)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 87, end: 88),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 88, end: 89)),
    token.Token(kind: token.Space, span: position.Span(start: 89, end: 90)),
    token.Token(kind: token.Space, span: position.Span(start: 90, end: 91)),
    token.Token(kind: token.RArrow, span: position.Span(start: 91, end: 93)),
    token.Token(kind: token.Space, span: position.Span(start: 93, end: 94)),
    token.Token(kind: token.Space, span: position.Span(start: 94, end: 95)),
    token.Token(kind: token.Space, span: position.Span(start: 95, end: 96)),
    token.Token(kind: token.Dot, span: position.Span(start: 96, end: 97)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 97, end: 98),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 98, end: 99)),
    token.Token(kind: token.Space, span: position.Span(start: 99, end: 100)),
    token.Token(kind: token.Space, span: position.Span(start: 100, end: 101)),
    token.Token(kind: token.RBrace, span: position.Span(start: 101, end: 102)),
  ]

  let assert Ok(#(operation, rest)) = parse_operation.parse(source, tokens)

  case operation {
    ast.Operation(inputs:, outputs:, operations:, expressions:) -> {
      assert inputs
        == [
          ast.Field(name: "a", annotation: ast.NamedTypeAnnotation("Int")),
          ast.Field(name: "b", annotation: ast.NamedTypeAnnotation("String")),
        ]

      assert outputs
        == [
          ast.Field(name: "c", annotation: ast.NamedTypeAnnotation("Float")),
          ast.Field(name: "d", annotation: ast.NamedTypeAnnotation("Bool")),
        ]

      assert operations
        == [
          ast.NestedOperation(
            name: "Inner",
            inputs: [
              ast.Field(name: "x", annotation: ast.NamedTypeAnnotation("Int")),
            ],
            outputs: [
              ast.Field(name: "y", annotation: ast.NamedTypeAnnotation("Int")),
            ],
            operations: [],
            expressions: [],
          ),
        ]

      assert list.length(expressions) == 1
      assert rest == []
    }

    _ -> panic
  }
}

pub fn parse_preserves_remaining_tokens_after_operation_test() {
  let source = "-> out: Int {} tail"

  let tokens = [
    token.Token(kind: token.RArrow, span: position.Span(start: 0, end: 2)),
    token.Token(kind: token.Space, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(kind: token.LBrace, span: position.Span(start: 12, end: 13)),
    token.Token(kind: token.RBrace, span: position.Span(start: 13, end: 14)),
    token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 15, end: 19),
    ),
  ]

  let assert Ok(#(operation, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      inputs: [],
      outputs: [
        ast.Field(name: "out", annotation: ast.NamedTypeAnnotation("Int")),
      ],
      operations: [],
      expressions: [],
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 14, end: 15)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 15, end: 19),
      ),
    ]
}
