import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_reference
import webql/lang/source/position

pub fn parse_node_port_reference_test() {
  let source = "m.out"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Dot, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 5),
    ),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.NodePortReference(alias: "m", port: "out")
  assert rest == []
}

pub fn parse_operation_port_reference_test() {
  let source = ".out"
  let tokens = [
    token.Token(kind: token.Dot, span: position.Span(start: 0, end: 1)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 1, end: 4),
    ),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.OperationPortReference(port: "out")
  assert rest == []
}

pub fn parse_int_value_reference_test() {
  let source = "123"
  let tokens = [
    token.Token(kind: token.Int, span: position.Span(start: 0, end: 3)),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.ValueReference(value: ast.IntValue(value: 123))
  assert rest == []
}

pub fn parse_float_value_reference_test() {
  let source = "1.23"
  let tokens = [
    token.Token(kind: token.Float, span: position.Span(start: 0, end: 4)),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.ValueReference(value: ast.FloatValue(value: 1.23))
  assert rest == []
}

pub fn parse_string_value_reference_test() {
  let source = "\"test\""
  let tokens = [
    token.Token(kind: token.String, span: position.Span(start: 0, end: 6)),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.ValueReference(value: ast.StringValue(value: "test"))
  assert rest == []
}

pub fn parse_skips_leading_spaces_before_operation_port_reference_test() {
  let source = " .out"
  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Dot, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 5),
    ),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.OperationPortReference(port: "out")
  assert rest == []
}

pub fn parse_returns_error_when_space_exists_between_node_alias_and_dot_test() {
  let source = "m .out"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.Dot, span: position.Span(start: 2, end: 3)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 3, end: 6),
    ),
  ]

  let assert Error(error) = parse_reference.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: position.Span(start: 1, end: 2),
    )
}

pub fn parse_preserves_remaining_tokens_after_reference_test() {
  let source = "m.out next"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Dot, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 5),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 6, end: 10),
    ),
  ]

  let assert Ok(#(reference, rest)) = parse_reference.parse(source, tokens)

  assert reference == ast.NodePortReference(alias: "m", port: "out")
  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 6, end: 10),
      ),
    ]
}
