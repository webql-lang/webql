import webql/compiler/lexer
import webql/compiler/parser_1
import webql/compiler/source

pub fn parse_consumes_lexer_eof_test() {
  let assert Ok(parser_1.Ast(
    ports: [],
    elements: [],
    span: source.Span(start: 0, end: 5),
  )) = parse("-> {}")
}

pub fn parse_allows_every_interface_cardinality_test() {
  let assert Ok(parser_1.Ast(ports: [], ..)) = parse("-> {}")

  let assert Ok(parser_1.Ast(ports: [parser_1.Output(name: "out", ..)], ..)) =
    parse("-> out: Int {}")

  let assert Ok(parser_1.Ast(ports: [parser_1.Input(name: "in", ..)], ..)) =
    parse("in: Int -> {}")

  let assert Ok(parser_1.Ast(
    ports: [parser_1.Input(name: "in", ..), parser_1.Output(name: "out", ..)],
    ..,
  )) = parse("in: Int -> out: Int {}")

  let assert Ok(parser_1.Ast(
    ports: [
      parser_1.Input(name: "a", ..),
      parser_1.Input(name: "b", ..),
      parser_1.Output(name: "x", ..),
      parser_1.Output(name: "y", ..),
    ],
    ..,
  )) = parse("a: A, b: B -> x: X, y: Y {}")
}

pub fn parse_allows_empty_nested_block_interfaces_test() {
  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Labeled(
        name: "Inner",
        value: parser_1.Block(parser_1.Ast(ports: [], elements: [], ..), ..),
        ..,
      ),
    ],
    ..,
  )) = parse("-> { Inner = -> {} }")
}

pub fn parse_returns_unexpected_eof_for_unterminated_block_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedEof,
    span: source.Span(start: 4, end: 4),
  )) = parse("-> {")
}

pub fn parse_requires_terminal_eof_test() {
  let source = "-> {}"
  let assert Ok([
    arrow,
    left_brace,
    right_brace,
    lexer.Token(kind: lexer.EOF, ..),
  ]) = lexer.lex(source)

  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedEof,
    span: source.Span(start: 5, end: 5),
  )) = parser_1.parse(source, [arrow, left_brace, right_brace])
}

pub fn parse_rejects_tokens_after_document_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.LowerIdentifier,
      expected: parser_1.ExpectedElement,
    ),
    span: source.Span(start: 6, end: 14),
  )) = parse("-> {} trailing")
}

pub fn parse_allows_literal_edge_sources_test() {
  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Unlabeled(
        parser_1.Edge(from: parser_1.Source(parser_1.Int(value: 1, ..), ..), ..),
        ..,
      ),
    ],
    ..,
  )) = parse("-> out: Int { 1 -> .out }")
}

pub fn parse_rejects_literal_edge_targets_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Int,
      expected: parser_1.ExpectedPath,
    ),
    ..,
  )) = parse("-> out: Int { .out -> 1 }")
}

pub fn parse_requires_unlabeled_members_to_form_edges_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.Dot,
      expected: parser_1.ExpectedToken(lexer.RArrow),
    ),
    ..,
  )) = parse("in: Int -> out: Int { .in .out }")
}

pub fn parse_requires_unlabeled_literals_to_form_edges_test() {
  let assert Error(parser_1.Diagnostic(
    kind: parser_1.UnexpectedToken(
      found: lexer.RBrace,
      expected: parser_1.ExpectedToken(lexer.RArrow),
    ),
    ..,
  )) = parse("-> out: Int { 1 }")
}

pub fn parse_preserves_labeled_non_edge_values_test() {
  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Labeled(
        name: "node",
        value: parser_1.Member(parser_1.Neighbor(["Math"]), ..),
        ..,
      ),
      parser_1.Labeled(
        name: "one",
        value: parser_1.Literal(parser_1.Int(value: 1, ..), ..),
        ..,
      ),
    ],
    ..,
  )) = parse("-> { node = Math one = 1 }")
}

pub fn parse_distinguishes_interface_and_local_paths_test() {
  let assert Ok(parser_1.Ast(
    elements: [
      parser_1.Unlabeled(
        parser_1.Edge(
          from: parser_1.Reference(parser_1.Port("x"), ..),
          to: parser_1.Reference(parser_1.Neighbor(["sink", "in"]), ..),
          ..,
        ),
        ..,
      ),
      parser_1.Unlabeled(
        parser_1.Edge(
          from: parser_1.Reference(parser_1.Neighbor(["x"]), ..),
          to: parser_1.Reference(parser_1.Port("x"), ..),
          ..,
        ),
        ..,
      ),
      parser_1.Labeled(
        name: "dotted",
        value: parser_1.Member(parser_1.Port("x"), ..),
        ..,
      ),
      parser_1.Labeled(
        name: "bare",
        value: parser_1.Member(parser_1.Neighbor(["x"]), ..),
        ..,
      ),
    ],
    ..,
  )) = parse("-> { .x -> sink.in x -> .x dotted = .x bare = x }")
}

fn parse(source: String) {
  let assert Ok(tokens) = lexer.lex(source)
  parser_1.parse(source, tokens)
}
