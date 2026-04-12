import gleeunit/should
import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/parse_expression
import webql/lang/source

pub fn parse_binding_expression_test() {
  let source = "m = Math"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Binding(
      span: source.Span(start: 0, end: 8),
      name: "m",
      value: ast.Node(name: "Math", span: source.Span(start: 4, end: 8)),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Binding(
      span: source.Span(start: 0, end: 6),
      name: "m",
      value: ast.Node(name: "Math", span: source.Span(start: 2, end: 6)),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 13),
      from: ast.Access(span: source.Span(start: 0, end: 5), path: ["m", "out"]),
      to: ast.Access(span: source.Span(start: 9, end: 13), path: ["out"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 10),
      from: ast.Access(span: source.Span(start: 0, end: 3), path: ["in"]),
      to: ast.Access(span: source.Span(start: 7, end: 10), path: ["m", "l"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 8),
      from: ast.Literal(
        span: source.Span(start: 0, end: 1),
        value: ast.Int(span: source.Span(start: 0, end: 1), value: 1),
      ),
      to: ast.Access(span: source.Span(start: 5, end: 8), path: ["m", "l"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 11),
      from: ast.Literal(
        span: source.Span(start: 0, end: 4),
        value: ast.Float(span: source.Span(start: 0, end: 4), value: 1.23),
      ),
      to: ast.Access(span: source.Span(start: 8, end: 11), path: ["m", "l"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 14),
      from: ast.Literal(
        span: source.Span(start: 0, end: 6),
        value: ast.String(span: source.Span(start: 0, end: 6), value: "test"),
      ),
      to: ast.Access(span: source.Span(start: 10, end: 14), path: ["out"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Binding(
      span: source.Span(start: 2, end: 10),
      name: "m",
      value: ast.Node(name: "Math", span: source.Span(start: 6, end: 10)),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 15),
      from: ast.Access(span: source.Span(start: 0, end: 7), path: ["m", "out"]),
      to: ast.Access(span: source.Span(start: 11, end: 15), path: ["out"]),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Binding(
      span: source.Span(start: 0, end: 8),
      name: "m",
      value: ast.Node(name: "Math", span: source.Span(start: 4, end: 8)),
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

  let assert Ok(cursor.Cursor(current: expression, rest:, ..)) =
    parse_expression.parse(source, tokens)

  should.equal(
    expression,
    ast.Edge(
      span: source.Span(start: 0, end: 11),
      from: ast.Access(span: source.Span(start: 0, end: 3), path: ["in"]),
      to: ast.Access(span: source.Span(start: 7, end: 11), path: ["out"]),
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
