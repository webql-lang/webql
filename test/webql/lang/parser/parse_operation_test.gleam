import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_operation
import webql/lang/source/position

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
      span: position.Span(start: 0, end: 79),
      inputs: [
        ast.Field(
          span: position.Span(start: 0, end: 6),
          name: "a",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 3, end: 6),
            name: "Int",
          ),
        ),
        ast.Field(
          span: position.Span(start: 8, end: 17),
          name: "b",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 11, end: 17),
            name: "String",
          ),
        ),
      ],
      outputs: [
        ast.Field(
          span: position.Span(start: 21, end: 29),
          name: "c",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 24, end: 29),
            name: "Float",
          ),
        ),
        ast.Field(
          span: position.Span(start: 31, end: 38),
          name: "d",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 34, end: 38),
            name: "Bool",
          ),
        ),
      ],
      operations: [
        ast.NestedOperation(
          span: position.Span(start: 41, end: 68),
          name: "Inner",
          inputs: [
            ast.Field(
              span: position.Span(start: 49, end: 55),
              name: "x",
              annotation: ast.NamedTypeAnnotation(
                span: position.Span(start: 52, end: 55),
                name: "Int",
              ),
            ),
          ],
          outputs: [
            ast.Field(
              span: position.Span(start: 59, end: 65),
              name: "y",
              annotation: ast.NamedTypeAnnotation(
                span: position.Span(start: 62, end: 65),
                name: "Int",
              ),
            ),
          ],
          operations: [],
          expressions: [],
        ),
      ],
      expressions: [
        ast.EdgeExpression(
          span: position.Span(start: 69, end: 77),
          from: ast.OperationPortReference(
            span: position.Span(start: 69, end: 71),
            port: "a",
          ),
          to: ast.OperationPortReference(
            span: position.Span(start: 75, end: 77),
            port: "c",
          ),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 79, end: 79))]
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
      span: position.Span(start: 2, end: 102),
      inputs: [
        ast.Field(
          span: position.Span(start: 2, end: 8),
          name: "a",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 5, end: 8),
            name: "Int",
          ),
        ),
        ast.Field(
          span: position.Span(start: 11, end: 20),
          name: "b",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 14, end: 20),
            name: "String",
          ),
        ),
      ],
      outputs: [
        ast.Field(
          span: position.Span(start: 28, end: 36),
          name: "c",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 31, end: 36),
            name: "Float",
          ),
        ),
        ast.Field(
          span: position.Span(start: 39, end: 46),
          name: "d",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 42, end: 46),
            name: "Bool",
          ),
        ),
      ],
      operations: [
        ast.NestedOperation(
          span: position.Span(start: 51, end: 83),
          name: "Inner",
          inputs: [
            ast.Field(
              span: position.Span(start: 63, end: 69),
              name: "x",
              annotation: ast.NamedTypeAnnotation(
                span: position.Span(start: 66, end: 69),
                name: "Int",
              ),
            ),
          ],
          outputs: [
            ast.Field(
              span: position.Span(start: 73, end: 79),
              name: "y",
              annotation: ast.NamedTypeAnnotation(
                span: position.Span(start: 76, end: 79),
                name: "Int",
              ),
            ),
          ],
          operations: [],
          expressions: [],
        ),
      ],
      expressions: [
        ast.EdgeExpression(
          span: position.Span(start: 86, end: 98),
          from: ast.OperationPortReference(
            span: position.Span(start: 86, end: 88),
            port: "a",
          ),
          to: ast.OperationPortReference(
            span: position.Span(start: 96, end: 98),
            port: "c",
          ),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 102, end: 102))]
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
      span: position.Span(start: 0, end: 14),
      inputs: [],
      outputs: [
        ast.Field(
          span: position.Span(start: 3, end: 11),
          name: "out",
          annotation: ast.NamedTypeAnnotation(
            span: position.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
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
      token.Token(kind: token.EOF, span: position.Span(start: 19, end: 19)),
    ]
}
