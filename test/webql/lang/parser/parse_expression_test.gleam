import gleeunit
import gleeunit/should
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_expression
import webql/lang/source/position

pub fn main() {
  gleeunit.main()
}

pub fn parse_binding_expression_test() {
  let source = "m = Math"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.Equal, span: position.Span(start: 2, end: 3)),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 4, end: 8),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(expression, ast.BindingExpression(alias: "m", node: "Math"))
  should.equal(rest, [])
}

pub fn parse_binding_expression_without_spaces_test() {
  let source = "m=Math"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Equal, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 2, end: 6),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(expression, ast.BindingExpression(alias: "m", node: "Math"))
  should.equal(rest, [])
}

pub fn parse_node_port_edge_expression_test() {
  let source = "m.out -> .out"
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
    token.Token(kind: token.RArrow, span: position.Span(start: 6, end: 8)),
    token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
    token.Token(kind: token.Dot, span: position.Span(start: 9, end: 10)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 10, end: 13),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.NodePortReference(alias: "m", port: "out"),
      to: ast.OperationPortReference(port: "out"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_operation_port_edge_expression_test() {
  let source = ".in -> m.l"
  let tokens = [
    token.Token(kind: token.Dot, span: position.Span(start: 0, end: 1)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 1, end: 3),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(kind: token.RArrow, span: position.Span(start: 4, end: 6)),
    token.Token(kind: token.Space, span: position.Span(start: 6, end: 7)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 7, end: 8),
    ),
    token.Token(kind: token.Dot, span: position.Span(start: 8, end: 9)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 9, end: 10),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.OperationPortReference(port: "in"),
      to: ast.NodePortReference(alias: "m", port: "l"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_int_value_edge_expression_test() {
  let source = "1 -> m.l"
  let tokens = [
    token.Token(kind: token.Int, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.RArrow, span: position.Span(start: 2, end: 4)),
    token.Token(kind: token.Space, span: position.Span(start: 4, end: 5)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 5, end: 6),
    ),
    token.Token(kind: token.Dot, span: position.Span(start: 6, end: 7)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 7, end: 8),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.ValueReference(value: ast.IntValue(value: 1)),
      to: ast.NodePortReference(alias: "m", port: "l"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_float_value_edge_expression_test() {
  let source = "1.23 -> m.l"
  let tokens = [
    token.Token(kind: token.Float, span: position.Span(start: 0, end: 4)),
    token.Token(kind: token.Space, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.RArrow, span: position.Span(start: 5, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 8, end: 9),
    ),
    token.Token(kind: token.Dot, span: position.Span(start: 9, end: 10)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 10, end: 11),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.ValueReference(value: ast.FloatValue(value: 1.23)),
      to: ast.NodePortReference(alias: "m", port: "l"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_string_value_edge_expression_test() {
  let source = "\"test\" -> .out"
  let tokens = [
    token.Token(kind: token.String, span: position.Span(start: 0, end: 6)),
    token.Token(kind: token.Space, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.RArrow, span: position.Span(start: 7, end: 9)),
    token.Token(kind: token.Space, span: position.Span(start: 9, end: 10)),
    token.Token(kind: token.Dot, span: position.Span(start: 10, end: 11)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 11, end: 14),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.ValueReference(value: ast.StringValue(value: "test")),
      to: ast.OperationPortReference(port: "out"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_skips_leading_spaces_test() {
  let source = "  m = Math"
  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 3),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(kind: token.Equal, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 6, end: 10),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(expression, ast.BindingExpression(alias: "m", node: "Math"))
  should.equal(rest, [])
}

pub fn parse_skips_spaces_inside_node_port_edge_expression_test() {
  let source = "m . out -> .out"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.Dot, span: position.Span(start: 2, end: 3)),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 4, end: 7),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(kind: token.RArrow, span: position.Span(start: 8, end: 10)),
    token.Token(kind: token.Space, span: position.Span(start: 10, end: 11)),
    token.Token(kind: token.Dot, span: position.Span(start: 11, end: 12)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 12, end: 15),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.NodePortReference(alias: "m", port: "out"),
      to: ast.OperationPortReference(port: "out"),
    ),
  )

  should.equal(rest, [])
}

pub fn parse_preserves_remaining_tokens_after_binding_expression_test() {
  let source = "m = Math other"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 1),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(kind: token.Equal, span: position.Span(start: 2, end: 3)),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 4, end: 8),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 9, end: 14),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)
  should.equal(expression, ast.BindingExpression(alias: "m", node: "Math"))

  should.equal(rest, [
    token.Token(kind: token.Space, span: position.Span(start: 8, end: 9)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 9, end: 14),
    ),
  ])
}

pub fn parse_preserves_remaining_tokens_after_edge_expression_test() {
  let source = ".in -> .out extra"
  let tokens = [
    token.Token(kind: token.Dot, span: position.Span(start: 0, end: 1)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 1, end: 3),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(kind: token.RArrow, span: position.Span(start: 4, end: 6)),
    token.Token(kind: token.Space, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Dot, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 8, end: 11),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 12, end: 17),
    ),
  ]

  let assert Ok(#(expression, rest)) = parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      from: ast.OperationPortReference(port: "in"),
      to: ast.OperationPortReference(port: "out"),
    ),
  )

  should.equal(rest, [
    token.Token(kind: token.Space, span: position.Span(start: 11, end: 12)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 12, end: 17),
    ),
  ])
}
