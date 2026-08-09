import gleam/option
import webql/compiler/lexer
import webql/compiler/parser_1
import webql/compiler/source

pub fn from_ordered_ast_test() {
  let assert Ok(parser_1.Ast(
    parameters: [
      parser_1.Declaration(name: "first_param", typename: "A", ..),
      parser_1.Declaration(name: "second_param", typename: "B", ..),
    ],
    returns: [
      parser_1.Declaration(name: "first_return", typename: "X", ..),
      parser_1.Declaration(name: "second_return", typename: "Y", ..),
    ],
    elements: [
      parser_1.Definition(
        name: "integer_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Int(1, ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "float_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Float(1.25, ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "string_value",
        typename: option.None,
        element: parser_1.Value(parser_1.String("hello", ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "port_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Port("token_port", ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "node_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Node(["Math"], ..), ..),
        ..,
      ),
      parser_1.Edge(
        from: parser_1.Vertex(["local_value"], ..),
        to: parser_1.Port("output_port", ..),
        ..,
      ),
      parser_1.Definition(
        name: "qualified_node",
        typename: option.None,
        element: parser_1.Value(parser_1.Node(["service_node", "Add"], ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "vertex_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Vertex(["local_value"], ..), ..),
        ..,
      ),
      parser_1.Definition(
        name: "qualified_vertex",
        typename: option.None,
        element: parser_1.Value(
          parser_1.Vertex(["operation_node", "out"], ..),
          ..,
        ),
        ..,
      ),
      parser_1.Edge(
        from: parser_1.Int(1, ..),
        to: parser_1.Vertex(["operation_node", "input"], ..),
        ..,
      ),
      parser_1.Definition(
        name: "bound_service",
        typename: option.None,
        element: parser_1.Edge(
          from: parser_1.Port("token_port", ..),
          to: parser_1.Node(["Service"], ..),
          ..,
        ),
        ..,
      ),
      parser_1.Definition(
        name: "InnerBlock",
        typename: option.None,
        element: parser_1.Block(
          parser_1.Ast(
            parameters: [
              parser_1.Declaration(name: "input_value", typename: "Int", ..),
            ],
            returns: [
              parser_1.Declaration(name: "output_value", typename: "Int", ..),
            ],
            elements: [
              parser_1.Edge(
                from: parser_1.Port("input_value", ..),
                to: parser_1.Port("output_value", ..),
                ..,
              ),
            ],
            ..,
          ),
          ..,
        ),
        ..,
      ),
    ],
    ..,
  )) =
    parse(
      "first_param: A, second_param: B -> first_return: X, second_return: Y {
        integer_value = 1
        float_value = 1.25
        string_value = \"hello\"
        port_value = .token_port
        node_value = Math
        local_value -> .output_port
        qualified_node = service_node.Add
        vertex_value = local_value
        qualified_vertex = operation_node.out
        1 -> operation_node.input
        bound_service = .token_port -> Service
        InnerBlock = input_value: Int -> output_value: Int {
          .input_value -> .output_value
        }
      }",
    )
}

pub fn parse_interface_cardinalities_test() {
  let assert Ok(parser_1.Ast(parameters: [], returns: [], elements: [], ..)) =
    parse("-> {}")

  let assert Ok(parser_1.Ast(
    parameters: [],
    returns: [parser_1.Declaration(name: "out", typename: "Int", ..)],
    elements: [],
    ..,
  )) = parse("-> out: Int {}")

  let assert Ok(parser_1.Ast(
    parameters: [parser_1.Declaration(name: "in", typename: "Int", ..)],
    returns: [],
    elements: [],
    ..,
  )) = parse("in: Int -> {}")
}

pub fn parse_spans_cover_interfaces_and_ast_test() {
  let assert Ok(parser_1.Ast(
    parameters: [
      parser_1.Declaration(
        name: "in",
        typename: "Int",
        span: source.Span(start: 0, end: 7),
      ),
    ],
    returns: [
      parser_1.Declaration(
        name: "out",
        typename: "Float",
        span: source.Span(start: 11, end: 21),
      ),
    ],
    elements: [],
    span: source.Span(start: 0, end: 24),
  )) = parse("in: Int -> out: Float {}")
}

pub fn parse_spans_cover_definitions_and_values_test() {
  let code =
    "-> { integer = 1 float = 2.5 string = \"x\" port = .port node = Math qualified_node = service.Add vertex = integer qualified_vertex = operation.out }"

  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Definition(
        name: "integer",
        element: parser_1.Value(
          parser_1.Int(1, span: int_span),
          span: int_value_span,
        ),
        span: int_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "float",
        element: parser_1.Value(
          parser_1.Float(2.5, span: float_span),
          span: float_value_span,
        ),
        span: float_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "string",
        element: parser_1.Value(
          parser_1.String("x", span: string_span),
          span: string_value_span,
        ),
        span: string_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "port",
        element: parser_1.Value(
          parser_1.Port("port", span: port_span),
          span: port_value_span,
        ),
        span: port_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "node",
        element: parser_1.Value(
          parser_1.Node(["Math"], span: node_span),
          span: node_value_span,
        ),
        span: node_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "qualified_node",
        element: parser_1.Value(
          parser_1.Node(["service", "Add"], span: qualified_node_span),
          span: qualified_node_value_span,
        ),
        span: qualified_node_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "vertex",
        element: parser_1.Value(
          parser_1.Vertex(["integer"], span: vertex_span),
          span: vertex_value_span,
        ),
        span: vertex_definition_span,
        ..,
      ),
      parser_1.Definition(
        name: "qualified_vertex",
        element: parser_1.Value(
          parser_1.Vertex(["operation", "out"], span: qualified_vertex_span),
          span: qualified_vertex_value_span,
        ),
        span: qualified_vertex_definition_span,
        ..,
      ),
    ],
    span: ast_span,
    ..,
  )) = parse(code)

  assert source.slice(code, ast_span) == code
  assert int_span == int_value_span
  assert source.slice(code, int_span) == "1"
  assert source.slice(code, int_definition_span) == "integer = 1"
  assert float_span == float_value_span
  assert source.slice(code, float_span) == "2.5"
  assert source.slice(code, float_definition_span) == "float = 2.5"
  assert string_span == string_value_span
  assert source.slice(code, string_span) == "\"x\""
  assert source.slice(code, string_definition_span) == "string = \"x\""
  assert port_span == port_value_span
  assert source.slice(code, port_span) == ".port"
  assert source.slice(code, port_definition_span) == "port = .port"
  assert node_span == node_value_span
  assert source.slice(code, node_span) == "Math"
  assert source.slice(code, node_definition_span) == "node = Math"
  assert qualified_node_span == qualified_node_value_span
  assert source.slice(code, qualified_node_span) == "service.Add"
  assert source.slice(code, qualified_node_definition_span)
    == "qualified_node = service.Add"
  assert vertex_span == vertex_value_span
  assert source.slice(code, vertex_span) == "integer"
  assert source.slice(code, vertex_definition_span) == "vertex = integer"
  assert qualified_vertex_span == qualified_vertex_value_span
  assert source.slice(code, qualified_vertex_span) == "operation.out"
  assert source.slice(code, qualified_vertex_definition_span)
    == "qualified_vertex = operation.out"
}

pub fn parse_spans_cover_edges_test() {
  let code = "-> { local -> .out service = .token -> Service }"

  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Edge(
        from: parser_1.Vertex(["local"], span: local_span),
        to: parser_1.Port("out", span: out_span),
        span: edge_span,
      ),
      parser_1.Definition(
        name: "service",
        element: parser_1.Edge(
          from: parser_1.Port("token", span: token_span),
          to: parser_1.Node(["Service"], span: service_span),
          span: bound_edge_span,
        ),
        span: definition_span,
        ..,
      ),
    ],
    ..,
  )) = parse(code)

  assert source.slice(code, local_span) == "local"
  assert source.slice(code, out_span) == ".out"
  assert source.slice(code, edge_span) == "local -> .out"
  assert source.slice(code, token_span) == ".token"
  assert source.slice(code, service_span) == "Service"
  assert source.slice(code, bound_edge_span) == ".token -> Service"
  assert source.slice(code, definition_span) == "service = .token -> Service"
}

pub fn parse_spans_cover_nested_blocks_test() {
  let code = "-> { Inner = in: Int -> out: Int { .in -> .out } }"

  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Definition(
        name: "Inner",
        element: parser_1.Block(
          parser_1.Ast(
            parameters: [parser_1.Declaration(name: "in", span: input_span, ..)],
            returns: [parser_1.Declaration(name: "out", span: output_span, ..)],
            elements: [
              parser_1.Edge(
                from: parser_1.Port("in", span: from_span),
                to: parser_1.Port("out", span: to_span),
                span: edge_span,
              ),
            ],
            span: nested_ast_span,
          ),
          span: block_span,
        ),
        span: definition_span,
        ..,
      ),
    ],
    span: ast_span,
    ..,
  )) = parse(code)

  assert source.slice(code, ast_span) == code
  assert source.slice(code, definition_span)
    == "Inner = in: Int -> out: Int { .in -> .out }"
  assert block_span == nested_ast_span
  assert source.slice(code, nested_ast_span)
    == "in: Int -> out: Int { .in -> .out }"
  assert source.slice(code, input_span) == "in: Int"
  assert source.slice(code, output_span) == "out: Int"
  assert source.slice(code, from_span) == ".in"
  assert source.slice(code, to_span) == ".out"
  assert source.slice(code, edge_span) == ".in -> .out"
}

pub fn parse_rejects_literal_edge_tos_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Int,
      expected: parser_1.ExpectedValue,
    ),
    ..,
  )) = parse("-> { .out -> 1 }")
}

pub fn parse_requires_unbound_values_to_form_edges_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.RBrace,
      expected: parser_1.ExpectedEdge,
    ),
    ..,
  )) = parse("-> { 1 }")
}

pub fn parse_reports_expected_ast_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.LBrace,
      expected: parser_1.ExpectedAst,
    ),
    span: source.Span(start: 0, end: 1),
  )) = parse("{}")
}

pub fn parse_reports_expected_element_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Equal,
      expected: parser_1.ExpectedElement,
    ),
    span: source.Span(start: 5, end: 6),
  )) = parse("-> { = }")
}

pub fn parse_reports_expected_block_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Int,
      expected: parser_1.ExpectedBlock,
    ),
    span: source.Span(start: 13, end: 14),
  )) = parse("-> { Inner = 1 }")
}

pub fn parse_reports_expected_port_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.RArrow,
      expected: parser_1.ExpectedPort,
    ),
    span: source.Span(start: 7, end: 9),
  )) = parse("-> { . -> .out }")
}

pub fn parse_rejects_invalid_numbers_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Int,
      expected: parser_1.ExpectedLiteral,
    ),
    ..,
  )) = parse("-> { value = 1__ }")

  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Float,
      expected: parser_1.ExpectedLiteral,
    ),
    ..,
  )) = parse("-> { value = 1.2.3 }")
}

pub fn parse_returns_unexpected_eof_for_unterminated_block_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedEof,
    span: source.Span(start: 4, end: 4),
  )) = parse("-> {")
}

pub fn parse_requires_terminal_eof_test() {
  let code = "-> {}"
  let assert Ok([arrow, left, right, lexer.Token(kind: lexer.EOF, ..)]) =
    lexer.lex(code)

  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedEof,
    span: source.Span(start: 5, end: 5),
  )) = parser_1.parse(code, [arrow, left, right])
}

pub fn parse_rejects_tokens_after_ast_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.LowerIdentifier,
      expected: parser_1.ExpectedToken(lexer.EOF),
    ),
    span: source.Span(start: 6, end: 14),
  )) = parse("-> {} trailing")
}

fn parse(code: String) {
  let assert Ok(tokens) = lexer.lex(code)
  parser_1.parse(code, tokens)
}
