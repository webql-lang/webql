import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_operation
import webql/compiler/source

pub fn parse_parses_operation_with_nested_operation_and_definition_test() {
  let source =
    "a: Int, b: String -> c: Float, d: Bool { Inner = x: Int -> y: Int {} .a -> .c }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(operation, _, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 79),
      parameters: [
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
      returns: [
        ast.Return(
          span: source.Span(start: 21, end: 29),
          name: "c",
          typename: ast.Typename(
            span: source.Span(start: 24, end: 29),
            name: "Float",
          ),
        ),
        ast.Return(
          span: source.Span(start: 31, end: 38),
          name: "d",
          typename: ast.Typename(
            span: source.Span(start: 34, end: 38),
            name: "Bool",
          ),
        ),
      ],
      definitions: [
        ast.Definition(
          span: source.Span(start: 41, end: 68),
          name: "Inner",
          operation: ast.Operation(
            span: source.Span(start: 49, end: 68),
            parameters: [
              ast.Parameter(
                span: source.Span(start: 49, end: 55),
                name: "x",
                typename: ast.Typename(
                  span: source.Span(start: 52, end: 55),
                  name: "Int",
                ),
              ),
            ],
            returns: [
              ast.Return(
                span: source.Span(start: 59, end: 65),
                name: "y",
                typename: ast.Typename(
                  span: source.Span(start: 62, end: 65),
                  name: "Int",
                ),
              ),
            ],
            definitions: [],
            bindings: [],
            edges: [],
          ),
        ),
      ],
      bindings: [],
      edges: [
        ast.Edge(
          span: source.Span(start: 69, end: 77),
          from: ast.PortOutput(span: source.Span(start: 69, end: 71), path: [
            "a",
          ]),
          to: ast.PortInput(span: source.Span(start: 75, end: 77), path: ["c"]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 79, end: 79))]
}

pub fn parse_skips_leading_and_internal_spaces_test() {
  let source = "  a: Int , b: String -> c: Bool { }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(operation, _, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 2, end: 35),
      parameters: [
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
      returns: [
        ast.Return(
          span: source.Span(start: 24, end: 31),
          name: "c",
          typename: ast.Typename(
            span: source.Span(start: 27, end: 31),
            name: "Bool",
          ),
        ),
      ],
      definitions: [],
      bindings: [],
      edges: [],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 35, end: 35))]
}

pub fn parse_parses_operation_body_with_lowercase_binding_and_edge_test() {
  let source = "-> out: Int { m = Math m.out -> .out }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(operation, _, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 38),
      parameters: [],
      returns: [
        ast.Return(
          span: source.Span(start: 3, end: 11),
          name: "out",
          typename: ast.Typename(
            span: source.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      definitions: [],
      bindings: [
        ast.Binding(
          span: source.Span(start: 14, end: 22),
          name: "m",
          value: ast.NodeValue(
            name: "Math",
            span: source.Span(start: 18, end: 22),
          ),
        ),
      ],
      edges: [
        ast.Edge(
          span: source.Span(start: 23, end: 36),
          from: ast.PortOutput(span: source.Span(start: 23, end: 28), path: [
            "m",
            "out",
          ]),
          to: ast.PortInput(span: source.Span(start: 32, end: 36), path: [
            "out",
          ]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 38, end: 38))]
}

pub fn parse_parses_binding_when_spaces_exist_before_equal_test() {
  let source = "-> out: Int { value   = 123 }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(operation, _, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 29),
      parameters: [],
      returns: [
        ast.Return(
          span: source.Span(start: 3, end: 11),
          name: "out",
          typename: ast.Typename(
            span: source.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      definitions: [],
      bindings: [
        ast.Binding(
          span: source.Span(start: 14, end: 27),
          name: "value",
          value: ast.PrimitiveValue(
            span: source.Span(start: 24, end: 27),
            value: ast.Int(
              name: "Int",
              span: source.Span(start: 24, end: 27),
              value: 123,
            ),
          ),
        ),
      ],
      edges: [],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 29, end: 29))]
}

pub fn parse_preserves_remaining_tokens_after_operation_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(operation, _, rest)) = parse_operation.parse(source, tokens)

  assert operation
    == ast.Operation(
      span: source.Span(start: 0, end: 14),
      parameters: [],
      returns: [
        ast.Return(
          span: source.Span(start: 3, end: 11),
          name: "out",
          typename: ast.Typename(
            span: source.Span(start: 8, end: 11),
            name: "Int",
          ),
        ),
      ],
      definitions: [],
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
