import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_reference
import webql/lang/source/position

pub fn parse_node_port_reference_test() {
  let source = "m.out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 5)

  assert reference
    == ast.NodePortReference(
      span: position.Span(start: 0, end: 5),
      alias: "m",
      port: "out",
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 5, end: 5))]
}

pub fn parse_operation_port_reference_test() {
  let source = ".out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 4)

  assert reference
    == ast.OperationPortReference(
      span: position.Span(start: 0, end: 4),
      port: "out",
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 4, end: 4))]
}

pub fn parse_int_value_reference_test() {
  let source = "123"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 3)

  assert reference
    == ast.ValueReference(
      span: position.Span(start: 0, end: 3),
      value: ast.IntValue(span: position.Span(start: 0, end: 3), value: 123),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 3, end: 3))]
}

pub fn parse_float_value_reference_test() {
  let source = "1.23"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 4)

  assert reference
    == ast.ValueReference(
      span: position.Span(start: 0, end: 4),
      value: ast.FloatValue(span: position.Span(start: 0, end: 4), value: 1.23),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 4, end: 4))]
}

pub fn parse_string_value_reference_test() {
  let source = "\"test\""

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 6)

  assert reference
    == ast.ValueReference(
      span: position.Span(start: 0, end: 6),
      value: ast.StringValue(
        span: position.Span(start: 0, end: 6),
        value: "test",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 6, end: 6))]
}

pub fn parse_skips_leading_spaces_before_operation_port_reference_test() {
  let source = " .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 1, end: 5)

  assert reference
    == ast.OperationPortReference(
      span: position.Span(start: 1, end: 5),
      port: "out",
    )

  assert rest
    == [token.Token(kind: token.EOF, span: position.Span(start: 5, end: 5))]
}

pub fn parse_returns_error_when_space_exists_between_node_alias_and_dot_test() {
  let source = "m .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_reference.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: position.Span(start: 1, end: 2),
    )
}

pub fn parse_preserves_remaining_tokens_after_reference_test() {
  let source = "m.out next"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: reference, span: span, tokens: rest)) =
    parse_reference.parse(source, tokens)

  assert span == position.Span(start: 0, end: 5)

  assert reference
    == ast.NodePortReference(
      span: position.Span(start: 0, end: 5),
      alias: "m",
      port: "out",
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 6, end: 10),
      ),
      token.Token(kind: token.EOF, span: position.Span(start: 10, end: 10)),
    ]
}
