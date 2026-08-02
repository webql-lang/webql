import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/source

pub fn parse_empty_graph_test() {
  let assert Ok(parser.Document(
    graph: parser.Graph(
      parameters: [],
      returns: [],
      nodes: [],
      edges: [],
      span: source.Span(start: 0, end: 5),
    ),
    span: source.Span(start: 0, end: 5),
  )) = parse_source("-> {}")
}

pub fn parse_allows_comments_before_inside_and_after_document_test() {
  let document_source = "# document\n-> out: Int { # body\n} # trailing"

  let assert Ok(parser.Document(
    span: source.Span(start: 11, end: 33),
    graph: parser.Graph(
      span: source.Span(start: 11, end: 33),
      parameters: [],
      returns: [
        parser.Return(
          span: source.Span(start: 14, end: 22),
          name: "out",
          port: parser.Port(span: source.Span(start: 19, end: 22), name: "Int"),
        ),
      ],
      nodes: [],
      edges: [],
    ),
  )) = parse_source(document_source)
}

pub fn parse_allows_trailing_whitespace_before_eof_test() {
  let assert Ok(parser.Document(
    span: source.Span(start: 0, end: 14),
    graph: parser.Graph(span: source.Span(start: 0, end: 14), ..),
  )) = parse_source("-> out: Int {}   ")
}

pub fn parse_parameters_and_returns_in_order_test() {
  let document_source =
    "first: Int, second: String, wide: Int32 -> result: Float, ok: Bool {}"

  let assert Ok(parser.Document(
    graph: parser.Graph(
      parameters: [
        parser.Parameter(name: "first", port: parser.Port(name: "Int", ..), ..),
        parser.Parameter(
          name: "second",
          port: parser.Port(name: "String", ..),
          ..,
        ),
        parser.Parameter(name: "wide", port: parser.Port(name: "Int32", ..), ..),
      ],
      returns: [
        parser.Return(name: "result", port: parser.Port(name: "Float", ..), ..),
        parser.Return(name: "ok", port: parser.Port(name: "Bool", ..), ..),
      ],
      ..,
    ),
    ..,
  )) = parse_source(document_source)
}

pub fn parse_nested_graph_nodes_and_edges_test() {
  let document_source =
    "in: Int -> out: Int { Inner = value: Int -> result: Int { .value -> .result } m = Math .in -> m.input m.output -> .out }"

  let assert Ok(parser.Document(
    graph: parser.Graph(
      nodes: [
        parser.Supernode(name: "Inner", graph: inner, ..),
        parser.Node(name: "m", node: "Math", ..),
      ],
      edges: [
        parser.Edge(
          source: parser.Output(path: ["in"], ..),
          target: parser.Input(path: ["m", "input"], ..),
          ..,
        ),
        parser.Edge(
          source: parser.Output(path: ["m", "output"], ..),
          target: parser.Input(path: ["out"], ..),
          ..,
        ),
      ],
      ..,
    ),
    ..,
  )) = parse_source(document_source)

  let assert parser.Graph(
    parameters: [parser.Parameter(name: "value", ..)],
    returns: [parser.Return(name: "result", ..)],
    edges: [
      parser.Edge(
        source: parser.Output(path: ["value"], ..),
        target: parser.Input(path: ["result"], ..),
        ..,
      ),
    ],
    ..,
  ) = inner
}

pub fn parse_literal_edge_sources_test() {
  let document_source =
    "-> int: Int, float: Float, string: String { 123 -> .int 1.25 -> .float \"test\" -> .string }"

  let assert Ok(parser.Document(
    graph: parser.Graph(
      edges: [
        parser.Edge(
          source: parser.Literal(
            value: parser.Int(name: "Int", value: 123, ..),
            ..,
          ),
          ..,
        ),
        parser.Edge(
          source: parser.Literal(
            value: parser.Float(name: "Float", value: 1.25, ..),
            ..,
          ),
          ..,
        ),
        parser.Edge(
          source: parser.Literal(
            value: parser.String(name: "String", value: "test", ..),
            ..,
          ),
          ..,
        ),
      ],
      ..,
    ),
    ..,
  )) = parse_source(document_source)
}

pub fn parse_preserves_multiple_nodes_and_edges_test() {
  let document_source =
    "-> left: Int, right: Int { a = Math b = Math a.out -> .left b.out -> .right }"

  let assert Ok(parser.Document(
    graph: parser.Graph(
      nodes: [
        parser.Node(name: "a", node: "Math", ..),
        parser.Node(name: "b", node: "Math", ..),
      ],
      edges: [
        parser.Edge(
          source: parser.Output(path: ["a", "out"], ..),
          target: parser.Input(path: ["left"], ..),
          ..,
        ),
        parser.Edge(
          source: parser.Output(path: ["b", "out"], ..),
          target: parser.Input(path: ["right"], ..),
          ..,
        ),
      ],
      ..,
    ),
    ..,
  )) = parse_source(document_source)
}

pub fn parse_errors_when_meaningful_tokens_remain_after_document_test() {
  assert_diagnostic(
    "-> out: Int {} next",
    parser.UnexpectedToken(lexer.LowerIdentifier),
    source.Span(start: 15, end: 19),
  )
}

pub fn parse_returns_unexpected_token_for_invalid_document_start_test() {
  assert_diagnostic(
    "{",
    parser.UnexpectedToken(lexer.LBrace),
    source.Span(start: 0, end: 1),
  )
}

pub fn parse_returns_unexpected_eof_for_empty_input_test() {
  assert_diagnostic("", parser.UnexpectedEof, source.Span(start: 0, end: 0))
}

pub fn parse_returns_unexpected_eof_for_unterminated_graph_test() {
  assert_diagnostic(
    "-> out: Int {",
    parser.UnexpectedEof,
    source.Span(start: 13, end: 13),
  )
}

pub fn parse_rejects_parameter_without_colon_test() {
  assert_diagnostic(
    "name String -> {}",
    parser.UnexpectedToken(lexer.UpperIdentifier),
    source.Span(start: 5, end: 11),
  )
}

pub fn parse_rejects_parameter_without_port_test() {
  assert_diagnostic(
    "name:",
    parser.UnexpectedEof,
    source.Span(start: 5, end: 5),
  )
}

pub fn parse_rejects_uppercase_parameter_name_test() {
  assert_diagnostic(
    "ok: Int, Name: Int -> {}",
    parser.UnexpectedToken(lexer.UpperIdentifier),
    source.Span(start: 9, end: 13),
  )
}

pub fn parse_rejects_lowercase_parameter_port_test() {
  assert_diagnostic(
    "name: int -> {}",
    parser.UnexpectedToken(lexer.LowerIdentifier),
    source.Span(start: 6, end: 9),
  )
}

pub fn parse_rejects_return_without_colon_test() {
  assert_diagnostic(
    "-> name String {}",
    parser.UnexpectedToken(lexer.UpperIdentifier),
    source.Span(start: 8, end: 14),
  )
}

pub fn parse_rejects_return_without_port_test() {
  assert_diagnostic(
    "-> name: {",
    parser.UnexpectedToken(lexer.LBrace),
    source.Span(start: 9, end: 10),
  )
}

pub fn parse_rejects_literal_node_value_test() {
  assert_diagnostic(
    "-> { count = 123 }",
    parser.UnexpectedToken(lexer.Int),
    source.Span(start: 13, end: 16),
  )
}

pub fn parse_rejects_node_without_value_test() {
  assert_diagnostic(
    "-> { m =",
    parser.UnexpectedEof,
    source.Span(start: 8, end: 8),
  )
}

pub fn parse_rejects_lowercase_supernode_name_test() {
  assert_diagnostic(
    "-> { inner = -> {} }",
    parser.UnexpectedToken(lexer.RArrow),
    source.Span(start: 13, end: 15),
  )
}

pub fn parse_accepts_space_between_source_alias_and_port_test() {
  let assert Ok(parser.Document(
    graph: parser.Graph(
      edges: [parser.Edge(source: parser.Output(path: ["m", "out"], ..), ..)],
      ..,
    ),
    ..,
  )) = parse_source("-> { m .out -> .out }")
}

pub fn parse_accepts_space_between_target_alias_and_port_test() {
  let assert Ok(parser.Document(
    graph: parser.Graph(
      edges: [parser.Edge(target: parser.Input(path: ["m", "in"], ..), ..)],
      ..,
    ),
    ..,
  )) = parse_source("-> { .out -> m .in }")
}

pub fn parse_rejects_graph_source_without_port_name_test() {
  assert_diagnostic(
    "-> { .",
    parser.UnexpectedToken(lexer.EOF),
    source.Span(start: 6, end: 6),
  )
}

pub fn parse_rejects_node_source_without_port_name_test() {
  assert_diagnostic(
    "-> { m.",
    parser.UnexpectedToken(lexer.EOF),
    source.Span(start: 7, end: 7),
  )
}

pub fn parse_rejects_edge_without_target_test() {
  assert_diagnostic(
    "-> { .in ->",
    parser.UnexpectedEof,
    source.Span(start: 11, end: 11),
  )
}

pub fn parse_rejects_literal_edge_target_test() {
  assert_diagnostic(
    "-> { .in -> \"out\" }",
    parser.UnexpectedToken(lexer.String),
    source.Span(start: 12, end: 17),
  )
}

pub fn parse_rejects_uppercase_edge_target_test() {
  assert_diagnostic(
    "-> { .in -> Math }",
    parser.UnexpectedToken(lexer.UpperIdentifier),
    source.Span(start: 12, end: 16),
  )
}

pub fn parse_rejects_missing_edge_arrow_test() {
  assert_diagnostic(
    "-> { .in .out }",
    parser.UnexpectedToken(lexer.Dot),
    source.Span(start: 9, end: 10),
  )
}

pub fn parse_rejects_invalid_float_test() {
  assert_diagnostic(
    "-> { 1.2.3 -> .out }",
    parser.UnexpectedToken(lexer.Float),
    source.Span(start: 5, end: 10),
  )
}

fn parse_source(document_source: String) {
  let assert Ok(tokens) = lexer.lex(document_source)
  parser.parse(document_source, tokens)
}

fn assert_diagnostic(
  document_source: String,
  kind: parser.DiagnosticKind,
  span: source.Span,
) {
  let assert Error(error) = parse_source(document_source)
  assert error == parser.Diagnostic(kind:, span:)
}
