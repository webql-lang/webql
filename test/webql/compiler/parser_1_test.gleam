import gleam/option
import webql/compiler/lexer
import webql/compiler/parser_1
import webql/compiler/source

pub fn from_ordered_ast_test() {
  let assert Ok(parser_1.Ast(
    parameters: [
      parser_1.Declaration(name: "first_param", typename: "A"),
      parser_1.Declaration(name: "second_param", typename: "B"),
    ],
    returns: [
      parser_1.Declaration(name: "first_return", typename: "X"),
      parser_1.Declaration(name: "second_return", typename: "Y"),
    ],
    elements: [
      parser_1.Definition(
        name: "integer_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Int(1)),
      ),
      parser_1.Definition(
        name: "float_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Float(1.25)),
      ),
      parser_1.Definition(
        name: "string_value",
        typename: option.None,
        element: parser_1.Value(parser_1.String("hello")),
      ),
      parser_1.Definition(
        name: "port_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Port("token_port")),
      ),
      parser_1.Definition(
        name: "node_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Node(["Math"])),
      ),
      parser_1.Edge(
        from: parser_1.Vertex(["local_value"]),
        to: parser_1.Port("output_port"),
      ),
      parser_1.Definition(
        name: "qualified_node",
        typename: option.None,
        element: parser_1.Value(parser_1.Node(["service_node", "Add"])),
      ),
      parser_1.Definition(
        name: "vertex_value",
        typename: option.None,
        element: parser_1.Value(parser_1.Vertex(["local_value"])),
      ),
      parser_1.Definition(
        name: "qualified_vertex",
        typename: option.None,
        element: parser_1.Value(parser_1.Vertex(["operation_node", "out"])),
      ),
      parser_1.Edge(
        from: parser_1.Int(1),
        to: parser_1.Vertex(["operation_node", "input"]),
      ),
      parser_1.Definition(
        name: "bound_service",
        typename: option.None,
        element: parser_1.Edge(
          from: parser_1.Port("token_port"),
          to: parser_1.Node(["Service"]),
        ),
      ),
      parser_1.Definition(
        name: "InnerBlock",
        typename: option.None,
        element: parser_1.Block(parser_1.Ast(
          parameters: [
            parser_1.Declaration(name: "input_value", typename: "Int"),
          ],
          returns: [parser_1.Declaration(name: "output_value", typename: "Int")],
          elements: [
            parser_1.Edge(
              from: parser_1.Port("input_value"),
              to: parser_1.Port("output_value"),
            ),
          ],
        )),
      ),
    ],
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
  let assert Ok(parser_1.Ast(parameters: [], returns: [], elements: [])) =
    parse("-> {}")

  let assert Ok(parser_1.Ast(
    parameters: [],
    returns: [parser_1.Declaration(name: "out", typename: "Int")],
    elements: [],
  )) = parse("-> out: Int {}")

  let assert Ok(parser_1.Ast(
    parameters: [parser_1.Declaration(name: "in", typename: "Int")],
    returns: [],
    elements: [],
  )) = parse("in: Int -> {}")
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
      expected: parser_1.ExpectedToken(lexer.RArrow),
    ),
    ..,
  )) = parse("-> { 1 }")
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
      expected: parser_1.ExpectedDeclaration,
    ),
    span: source.Span(start: 6, end: 14),
  )) = parse("-> {} trailing")
}

fn parse(code: String) {
  let assert Ok(tokens) = lexer.lex(code)
  parser_1.parse(code, tokens)
}
