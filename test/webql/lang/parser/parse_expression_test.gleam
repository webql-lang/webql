import gleeunit/should
import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_expression
import webql/lang/source

pub fn parse_binding_expression_test() {
  let source = "m = Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.BindingExpression(
      span: source.Span(start: 0, end: 8),
      alias: "m",
      node: "Math",
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 8, end: 8))]
}

pub fn parse_binding_expression_without_spaces_test() {
  let source = "m=Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.BindingExpression(
      span: source.Span(start: 0, end: 6),
      alias: "m",
      node: "Math",
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 6, end: 6))]
}

pub fn parse_node_port_edge_expression_test() {
  let source = "m.out -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 13),
      from: ast.NodePortReference(
        span: source.Span(start: 0, end: 5),
        alias: "m",
        port: "out",
      ),
      to: ast.OperationPortReference(
        span: source.Span(start: 9, end: 13),
        port: "out",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 13, end: 13))]
}

pub fn parse_operation_port_edge_expression_test() {
  let source = ".in -> m.l"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 10),
      from: ast.OperationPortReference(
        span: source.Span(start: 0, end: 3),
        port: "in",
      ),
      to: ast.NodePortReference(
        span: source.Span(start: 7, end: 10),
        alias: "m",
        port: "l",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 10, end: 10))]
}

pub fn parse_int_value_edge_expression_test() {
  let source = "1 -> m.l"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 8),
      from: ast.ValueReference(
        span: source.Span(start: 0, end: 1),
        value: ast.IntValue(span: source.Span(start: 0, end: 1), value: 1),
      ),
      to: ast.NodePortReference(
        span: source.Span(start: 5, end: 8),
        alias: "m",
        port: "l",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 8, end: 8))]
}

pub fn parse_float_value_edge_expression_test() {
  let source = "1.23 -> m.l"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 11),
      from: ast.ValueReference(
        span: source.Span(start: 0, end: 4),
        value: ast.FloatValue(span: source.Span(start: 0, end: 4), value: 1.23),
      ),
      to: ast.NodePortReference(
        span: source.Span(start: 8, end: 11),
        alias: "m",
        port: "l",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 11, end: 11))]
}

pub fn parse_string_value_edge_expression_test() {
  let source = "\"test\" -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 14),
      from: ast.ValueReference(
        span: source.Span(start: 0, end: 6),
        value: ast.StringValue(
          span: source.Span(start: 0, end: 6),
          value: "test",
        ),
      ),
      to: ast.OperationPortReference(
        span: source.Span(start: 10, end: 14),
        port: "out",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_skips_leading_spaces_test() {
  let source = "  m = Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.BindingExpression(
      span: source.Span(start: 2, end: 10),
      alias: "m",
      node: "Math",
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 10, end: 10))]
}

pub fn parse_skips_spaces_inside_node_port_edge_expression_test() {
  let source = "m . out -> .out"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 15),
      from: ast.NodePortReference(
        span: source.Span(start: 0, end: 7),
        alias: "m",
        port: "out",
      ),
      to: ast.OperationPortReference(
        span: source.Span(start: 11, end: 15),
        port: "out",
      ),
    ),
  )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 15, end: 15))]
}

pub fn parse_preserves_remaining_tokens_after_binding_expression_test() {
  let source = "m = Math other"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.BindingExpression(
      span: source.Span(start: 0, end: 8),
      alias: "m",
      node: "Math",
    ),
  )

  should.equal(rest, [
    token.Token(kind: token.Space, span: source.Span(start: 8, end: 9)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 9, end: 14),
    ),
    token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14)),
  ])
}

pub fn parse_preserves_remaining_tokens_after_edge_expression_test() {
  let source = ".in -> .out extra"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: expression, tokens: rest, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.EdgeExpression(
      span: source.Span(start: 0, end: 11),
      from: ast.OperationPortReference(
        span: source.Span(start: 0, end: 3),
        port: "in",
      ),
      to: ast.OperationPortReference(
        span: source.Span(start: 7, end: 11),
        port: "out",
      ),
    ),
  )

  should.equal(rest, [
    token.Token(kind: token.Space, span: source.Span(start: 11, end: 12)),
    token.Token(
      kind: token.LowerIdentifier,
      span: source.Span(start: 12, end: 17),
    ),
    token.Token(kind: token.EOF, span: source.Span(start: 17, end: 17)),
  ])
}
