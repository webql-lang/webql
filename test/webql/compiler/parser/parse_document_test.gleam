import webql/compiler/lexer
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_document
import webql/compiler/parser/parse_graph
import webql/compiler/source

pub fn parse_wraps_graph_test() {
  let source = "  -> out: Int {}"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(document, _, rest)) = parse_document.parse(source, tokens)
  let assert Ok(#(graph, _, _)) = parse_graph.parse(source, tokens)

  assert document.graph == graph
  assert document.span == source.Span(start: 2, end: 16)
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 16, end: 16))]
}

pub fn parse_preserves_remaining_tokens_after_document_test() {
  let source = "-> out: Int {} tail"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(document, _, rest)) = parse_document.parse(source, tokens)
  let assert Ok(#(graph, _, _)) = parse_graph.parse(source, tokens)

  assert document.graph == graph
  assert document.span == source.Span(start: 0, end: 14)
  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 14, end: 15)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 15, end: 19),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 19, end: 19)),
    ]
}

pub fn parse_returns_unexpected_token_for_invalid_document_start_test() {
  let source = "{"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_document.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.LBrace),
      span: source.Span(start: 0, end: 1),
    )
}
