import webql/compiler/lexer
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_source
import webql/compiler/source

pub fn parse_node_source_test() {
  let source = "m.out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(output, span, rest)) = parse_source.parse(source, tokens)

  assert span == source.Span(start: 0, end: 5)
  assert output
    == ast.Output(span: source.Span(start: 0, end: 5), path: ["m", "out"])

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 5, end: 5))]
}

pub fn parse_graph_source_test() {
  let source = ".out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(output, span, rest)) = parse_source.parse(source, tokens)

  assert span == source.Span(start: 0, end: 4)
  assert output
    == ast.Output(span: source.Span(start: 0, end: 4), path: ["out"])

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 4, end: 4))]
}

pub fn parse_static_test() {
  let source = "123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(#(output, span, rest)) = parse_source.parse(source, tokens)

  assert span == source.Span(start: 0, end: 3)
  assert output
    == ast.Static(
      span: source.Span(start: 0, end: 3),
      value: ast.Int(
        name: "Int",
        span: source.Span(start: 0, end: 3),
        value: 123,
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3))]
}

pub fn parse_returns_error_when_space_exists_between_node_alias_and_dot_test() {
  let source = "m .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_source.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: source.Span(start: 1, end: 2),
    )
}

pub fn parse_returns_unexpected_eof_when_graph_port_name_is_missing_test() {
  let source = "."

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_source.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.EOF),
      span: source.Span(start: 1, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_node_port_name_is_missing_test() {
  let source = "m."

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_source.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.EOF),
      span: source.Span(start: 2, end: 2),
    )
}

pub fn parse_returns_unexpected_token_for_invalid_output_start_test() {
  let source = "Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_source.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: source.Span(start: 0, end: 4),
    )
}
