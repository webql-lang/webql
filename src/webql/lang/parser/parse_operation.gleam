import gleam/list
import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_expression
import webql/lang/parser/parse_field
import webql/lang/parser/parse_nonstarter
import webql/lang/source
import webql/lang/source/position

/// Parses an operation.
///
/// ## Examples
///
///     .in -> .out { ... }
///     -> .out { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Operation), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..]
    | [token.Token(kind: token.Dot, span:), ..]
    | [token.Token(kind: token.RArrow, span:), ..] ->
      parse_root(source, tokens, span.start)

    _ -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

fn parse_root(
  source: String,
  tokens: List(token.Token),
  start: Int,
) -> Result(ast.Parsed(ast.Operation), diagnostic.Diagnostic) {
  use ast.Parsed(node: inputs, tokens: tokens, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use ast.Parsed(node: outputs, tokens: tokens, ..) <- result.try(
    parse_outputs(source, tokens, []),
  )
  use
    ast.Parsed(
      node: #(operations, expressions),
      span: body_span,
      tokens: tokens,
    )
  <- result.try(parse_body(source, tokens, #([], [])))

  let span = position.Span(start: start, end: body_span.end)

  Ok(ast.Parsed(
    node: ast.Operation(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      operations: list.reverse(operations),
      expressions: list.reverse(expressions),
    ),
    span:,
    tokens: tokens,
  ))
}

fn parse_nested(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Operation), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span: name_span), ..rest] -> {
      let name =
        ast.Parsed(
          node: source.slice(source, name_span),
          span: name_span,
          tokens: rest,
        )

      parse_nested_equal(source, name)
    }

    _ -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_nested(source, remaining)
    }
  }
}

fn parse_nested_equal(
  source: String,
  name: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Operation), diagnostic.Diagnostic) {
  case name.tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> {
      use operation <- result.try(parse_root(source, rest, name.span.start))

      case operation.node {
        ast.Operation(inputs:, outputs:, operations:, expressions:, ..) -> {
          let span =
            position.Span(start: name.span.start, end: operation.span.end)

          Ok(ast.Parsed(
            node: ast.NestedOperation(
              span: span,
              name: name.node,
              inputs: inputs,
              outputs: outputs,
              operations: operations,
              expressions: expressions,
            ),
            span: span,
            tokens: operation.tokens,
          ))
        }

        ast.NestedOperation(..) ->
          Ok(ast.Parsed(
            node: operation.node,
            span: operation.span,
            tokens: operation.tokens,
          ))
      }
    }

    _ -> {
      use tokens <- result.try(parse_nonstarter.parse(source, name.tokens))

      parse_nested_equal(
        source,
        ast.Parsed(node: name.node, span: name.span, tokens: tokens),
      )
    }
  }
}

fn parse_inputs(
  source: String,
  tokens: List(token.Token),
  inputs: List(ast.Field),
) -> Result(ast.Parsed(List(ast.Field)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use ast.Parsed(node: field, tokens: remaining, ..) <- result.try(
        parse_field.parse(source, tokens),
      )

      parse_inputs(source, remaining, [field, ..inputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_inputs(source, rest, inputs)

    [token.Token(kind: token.RArrow, span:), ..rest] ->
      Ok(ast.Parsed(node: inputs, span:, tokens: rest))

    _ -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_inputs(source, remaining, inputs)
    }
  }
}

fn parse_outputs(
  source: String,
  tokens: List(token.Token),
  outputs: List(ast.Field),
) -> Result(ast.Parsed(List(ast.Field)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use ast.Parsed(node: field, tokens: remaining, ..) <- result.try(
        parse_field.parse(source, tokens),
      )

      parse_outputs(source, remaining, [field, ..outputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_outputs(source, rest, outputs)

    [token.Token(kind: token.LBrace, span:), ..] ->
      Ok(ast.Parsed(node: outputs, span:, tokens: tokens))

    _ -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_outputs(source, remaining, outputs)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(token.Token),
  body: #(List(ast.Operation), List(ast.Expression)),
) -> Result(
  ast.Parsed(#(List(ast.Operation), List(ast.Expression))),
  diagnostic.Diagnostic,
) {
  let #(operations, expressions) = body

  case tokens {
    [token.Token(kind: token.LBrace, ..), ..rest] ->
      parse_body(source, rest, body)

    [token.Token(kind: token.RBrace, span: r_brace_span), ..rest] ->
      Ok(ast.Parsed(node: body, span: r_brace_span, tokens: rest))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use ast.Parsed(node: operation, tokens: remaining, ..) <- result.try(
        parse_nested(source, tokens),
      )

      parse_body(source, remaining, #([operation, ..operations], expressions))
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use ast.Parsed(node: expression, tokens: remaining, ..) <- result.try(
        parse_expression.parse(source, tokens),
      )

      parse_body(source, remaining, #(operations, [expression, ..expressions]))
    }

    _ -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_body(source, remaining, body)
    }
  }
}
