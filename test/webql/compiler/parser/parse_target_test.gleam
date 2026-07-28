import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_target
import webql/compiler/source

pub fn parse_node_target_test() {
  let source = "m.out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(input, span, rest)) = parse_target.parse(source, tokens)

  assert span == source.Span(start: 0, end: 5)
  assert input
    == ast.Input(span: source.Span(start: 0, end: 5), path: ["m", "out"])
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 5, end: 5))]
}

pub fn parse_graph_target_test() {
  let source = ".out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(input, span, rest)) = parse_target.parse(source, tokens)

  assert span == source.Span(start: 0, end: 4)
  assert input == ast.Input(span: source.Span(start: 0, end: 4), path: ["out"])
  assert rest
    == [lexer.Token(kind: lexer.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_preserves_remaining_tokens_after_input_test() {
  let source = "m.out next"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Ok(#(input, span, rest)) = parse_target.parse(source, tokens)

  assert span == source.Span(start: 0, end: 5)
  assert input
    == ast.Input(span: source.Span(start: 0, end: 5), path: ["m", "out"])
  assert rest
    == [
      lexer.Token(kind: lexer.Whitespace, span: source.Span(start: 5, end: 6)),
      lexer.Token(
        kind: lexer.LowerIdentifier,
        span: source.Span(start: 6, end: 10),
      ),
      lexer.Token(kind: lexer.EOF, span: source.Span(start: 10, end: 10)),
    ]
}

pub fn parse_returns_error_when_space_exists_between_node_alias_and_dot_test() {
  let source = "m .out"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_target.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.Whitespace),
      span: source.Span(start: 1, end: 2),
    )
}

pub fn parse_returns_unexpected_eof_when_graph_port_name_is_missing_test() {
  let source = "."

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_target.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.EOF),
      span: source.Span(start: 1, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_node_port_name_is_missing_test() {
  let source = "m."

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_target.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.EOF),
      span: source.Span(start: 2, end: 2),
    )
}

pub fn parse_returns_unexpected_token_for_invalid_input_start_test() {
  let source = "Math"

  let assert Ok(tokens) = lexer.tokenize(source)

  let assert Error(error) = parse_target.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(lexer.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
