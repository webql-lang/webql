import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_graph
import webql/compiler/source

pub fn parse_parses_graph_with_nested_graph_and_supernode_test() {
  let source =
    "a: Int, b: String -> c: Float, d: Bool { Inner = x: Int -> y: Int {} .a -> .c }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(graph, _, rest)) = parse_graph.parse(source, tokens)

  assert graph
    == ast.Graph(
      span: source.Span(start: 0, end: 79),
      parameters: [
        ast.Parameter(
          span: source.Span(start: 0, end: 6),
          name: "a",
          port: ast.Port(span: source.Span(start: 3, end: 6), name: "Int"),
        ),
        ast.Parameter(
          span: source.Span(start: 8, end: 17),
          name: "b",
          port: ast.Port(span: source.Span(start: 11, end: 17), name: "String"),
        ),
      ],
      returns: [
        ast.Return(
          span: source.Span(start: 21, end: 29),
          name: "c",
          port: ast.Port(span: source.Span(start: 24, end: 29), name: "Float"),
        ),
        ast.Return(
          span: source.Span(start: 31, end: 38),
          name: "d",
          port: ast.Port(span: source.Span(start: 34, end: 38), name: "Bool"),
        ),
      ],
      nodes: [
        ast.Supernode(
          span: source.Span(start: 41, end: 68),
          name: "Inner",
          graph: ast.Graph(
            span: source.Span(start: 49, end: 68),
            parameters: [
              ast.Parameter(
                span: source.Span(start: 49, end: 55),
                name: "x",
                port: ast.Port(
                  span: source.Span(start: 52, end: 55),
                  name: "Int",
                ),
              ),
            ],
            returns: [
              ast.Return(
                span: source.Span(start: 59, end: 65),
                name: "y",
                port: ast.Port(
                  span: source.Span(start: 62, end: 65),
                  name: "Int",
                ),
              ),
            ],
            nodes: [],
            edges: [],
          ),
        ),
      ],
      edges: [
        ast.Edge(
          span: source.Span(start: 69, end: 77),
          source: ast.Output(span: source.Span(start: 69, end: 71), path: [
            "a",
          ]),
          target: ast.Input(span: source.Span(start: 75, end: 77), path: ["c"]),
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

  let assert Ok(#(graph, _, rest)) = parse_graph.parse(source, tokens)

  assert graph
    == ast.Graph(
      span: source.Span(start: 2, end: 35),
      parameters: [
        ast.Parameter(
          span: source.Span(start: 2, end: 8),
          name: "a",
          port: ast.Port(span: source.Span(start: 5, end: 8), name: "Int"),
        ),
        ast.Parameter(
          span: source.Span(start: 11, end: 20),
          name: "b",
          port: ast.Port(span: source.Span(start: 14, end: 20), name: "String"),
        ),
      ],
      returns: [
        ast.Return(
          span: source.Span(start: 24, end: 31),
          name: "c",
          port: ast.Port(span: source.Span(start: 27, end: 31), name: "Bool"),
        ),
      ],
      nodes: [],
      edges: [],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 35, end: 35))]
}

pub fn parse_parses_graph_body_with_lowercase_node_and_edge_test() {
  let source = "-> out: Int { m = Math m.out -> .out }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(graph, _, rest)) = parse_graph.parse(source, tokens)

  assert graph
    == ast.Graph(
      span: source.Span(start: 0, end: 38),
      parameters: [],
      returns: [
        ast.Return(
          span: source.Span(start: 3, end: 11),
          name: "out",
          port: ast.Port(span: source.Span(start: 8, end: 11), name: "Int"),
        ),
      ],
      nodes: [
        ast.Node(span: source.Span(start: 14, end: 22), name: "m", node: "Math"),
      ],
      edges: [
        ast.Edge(
          span: source.Span(start: 23, end: 36),
          source: ast.Output(span: source.Span(start: 23, end: 28), path: [
            "m",
            "out",
          ]),
          target: ast.Input(span: source.Span(start: 32, end: 36), path: [
            "out",
          ]),
        ),
      ],
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 38, end: 38))]
}

pub fn parse_rejects_literal_node_when_spaces_exist_before_equal_test() {
  let source = "-> out: Int { value   = 123 }"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_graph.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Int),
      span: source.Span(start: 24, end: 27),
    )
}

pub fn parse_preserves_remaining_tokens_after_graph_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(graph, _, rest)) = parse_graph.parse(source, tokens)

  assert graph
    == ast.Graph(
      span: source.Span(start: 0, end: 14),
      parameters: [],
      returns: [
        ast.Return(
          span: source.Span(start: 3, end: 11),
          name: "out",
          port: ast.Port(span: source.Span(start: 8, end: 11), name: "Int"),
        ),
      ],
      nodes: [],
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

pub fn parse_returns_unexpected_token_for_invalid_graph_start_test() {
  let source = "{"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_graph.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_graph_body_is_unterminated_test() {
  let source = "-> out: Int {"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_graph.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 13, end: 13),
    )
}
