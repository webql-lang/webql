import webql/lexer
import webql/parser
import webql/source

pub fn parse_interface_and_edges_test() {
  let source =
    "value: Int -> out: Int { node = Math .value -> node.input node.output -> .out }"

  let assert Ok(parser.Ast(
    parameters: [
      parser.Declaration(name: "value", typename: "Int", span: parameter_span),
    ],
    returns: [
      parser.Declaration(name: "out", typename: "Int", span: return_span),
    ],
    elements: [
      parser.Definition(
        name: "node",
        element: parser.Value(parser.Node(["Math"], ..), ..),
        ..,
      ),
      parser.Edge(
        from: parser.Port("value", ..),
        to: parser.Vertex(["node", "input"], ..),
        span: input_edge_span,
      ),
      parser.Edge(
        from: parser.Vertex(["node", "output"], ..),
        to: parser.Port("out", ..),
        ..,
      ),
    ],
    span: ast_span,
  )) = parser.parse(source, lexer.lex_recovering(source))

  assert source.slice(source, parameter_span) == "value: Int"
  assert source.slice(source, return_span) == "out: Int"
  assert source.slice(source, input_edge_span) == ".value -> node.input"
  assert source.slice(source, ast_span) == source
}

pub fn parse_values_test() {
  let source =
    "-> { integer = 1 decimal = 1.5 text = \"hi\" port = .input node = Math owned = service.Add vertex = integer member = node.output }"

  let assert Ok(parser.Ast(
    elements: [
      parser.Definition(
        name: "integer",
        element: parser.Value(parser.Int(1, ..), ..),
        ..,
      ),
      parser.Definition(
        name: "decimal",
        element: parser.Value(parser.Float(1.5, ..), ..),
        ..,
      ),
      parser.Definition(
        name: "text",
        element: parser.Value(parser.String("hi", ..), ..),
        ..,
      ),
      parser.Definition(
        name: "port",
        element: parser.Value(parser.Port("input", ..), ..),
        ..,
      ),
      parser.Definition(
        name: "node",
        element: parser.Value(parser.Node(["Math"], ..), ..),
        ..,
      ),
      parser.Definition(
        name: "owned",
        element: parser.Value(parser.Node(["service", "Add"], ..), ..),
        ..,
      ),
      parser.Definition(
        name: "vertex",
        element: parser.Value(parser.Vertex(["integer"], ..), ..),
        ..,
      ),
      parser.Definition(
        name: "member",
        element: parser.Value(parser.Vertex(["node", "output"], ..), ..),
        ..,
      ),
    ],
    ..,
  )) = parser.parse(source, lexer.lex_recovering(source))
}

pub fn parse_nested_block_test() {
  let source =
    "-> { Identity = value: Int -> result: Int { .value -> .result } }"

  let assert Ok(parser.Ast(
    parameters: [],
    returns: [],
    elements: [
      parser.Definition(
        name: "Identity",
        element: parser.Block(
          parser.Ast(
            parameters: [parser.Declaration(name: "value", ..)],
            returns: [parser.Declaration(name: "result", ..)],
            elements: [
              parser.Edge(
                from: parser.Port("value", ..),
                to: parser.Port("result", ..),
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
  )) = parser.parse(source, lexer.lex_recovering(source))
}

pub fn parse_reports_unexpected_start_test() {
  let source = "{}"

  assert parser.parse(source, lexer.lex_recovering(source))
    == Error(parser.Diagnostic(
      kind: parser.UnexpectedToken(
        found: lexer.LBrace,
        expected: parser.ExpectedAst,
      ),
      span: source.Span(start: 0, end: 1),
    ))
}

pub fn parse_rejects_invalid_literals_test() {
  let source = "-> { value = 1__ }"

  assert parser.parse(source, lexer.lex_recovering(source))
    == Error(parser.Diagnostic(
      kind: parser.UnexpectedToken(
        found: lexer.Int,
        expected: parser.ExpectedLiteral,
      ),
      span: source.Span(start: 13, end: 16),
    ))
}

pub fn parse_reports_unterminated_blocks_test() {
  let source = "-> {"

  assert parser.parse(source, lexer.lex_recovering(source))
    == Error(parser.Diagnostic(
      kind: parser.UnexpectedEof,
      span: source.Span(start: 4, end: 4),
    ))
}

pub fn parse_rejects_trailing_tokens_test() {
  let source = "-> {} trailing"

  assert parser.parse(source, lexer.lex_recovering(source))
    == Error(parser.Diagnostic(
      kind: parser.UnexpectedToken(
        found: lexer.LowerIdentifier,
        expected: parser.ExpectedToken(lexer.EOF),
      ),
      span: source.Span(start: 6, end: 14),
    ))
}
