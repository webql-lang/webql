import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_graph
import webql/compiler/parser/parse_supernode
import webql/compiler/source

pub fn parse_supernode_test() {
  let source = "Inner = -> out: Int {}"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(supernode, _, rest)) =
    parse_supernode.parse(source, tokens, parse_graph.parse)

  assert supernode
    == ast.Supernode(
      span: source.Span(start: 0, end: 22),
      name: "Inner",
      graph: ast.Graph(
        span: source.Span(start: 8, end: 22),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 11, end: 19),
            name: "out",
            port: ast.Port(span: source.Span(start: 16, end: 19), name: "Int"),
          ),
        ],
        nodes: [],
        edges: [],
      ),
    )

  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 22, end: 22))]
}

pub fn parse_supernode_preserves_remaining_tokens_test() {
  let source = "Inner = -> out: Int {} next"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(supernode, _, rest)) =
    parse_supernode.parse(source, tokens, parse_graph.parse)

  assert supernode
    == ast.Supernode(
      span: source.Span(start: 0, end: 22),
      name: "Inner",
      graph: ast.Graph(
        span: source.Span(start: 8, end: 22),
        parameters: [],
        returns: [
          ast.Return(
            span: source.Span(start: 11, end: 19),
            name: "out",
            port: ast.Port(span: source.Span(start: 16, end: 19), name: "Int"),
          ),
        ],
        nodes: [],
        edges: [],
      ),
    )

  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 22, end: 23)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 23, end: 27),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 27, end: 27)),
    ]
}

pub fn parse_returns_unexpected_token_for_lower_identifier_supernode_name_test() {
  let source = "inner = -> out: Int {}"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) =
    parse_supernode.parse(source, tokens, parse_graph.parse)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.LowerIdentifier),
      span: source.Span(start: 0, end: 5),
    )
}
