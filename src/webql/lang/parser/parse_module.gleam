import gleam/list
import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_expression
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_parameter
import webql/lang/source

/// Parses a module.
///
/// ## Examples
///
///     .in -> .out { ... }
///     -> .out { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Module), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..]
    | [token.Token(kind: token.Dot, span:), ..]
    | [token.Token(kind: token.RArrow, span:), ..] ->
      parse_module(source, tokens, span.start)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_module(
  source: String,
  tokens: List(token.Token),
  start: Int,
) -> Result(ast.Parsed(ast.Module), diagnostic.Diagnostic) {
  use ast.Parsed(node: inputs, tokens:, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use ast.Parsed(node: outputs, tokens:, ..) <- result.try(
    parse_outputs(source, tokens, []),
  )
  use ast.Parsed(node: expressions, tokens:, ..) as body <- result.try(
    parse_body(source, tokens, []),
  )

  let span = source.Span(start: start, end: body.span.end)

  Ok(ast.Parsed(
    node: ast.Module(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      expressions: list.reverse(expressions),
    ),
    span:,
    tokens:,
  ))
}

fn parse_operation(
  source: String,
  tokens: List(token.Token),
  start: Int,
) -> Result(ast.Parsed(ast.Reference), diagnostic.Diagnostic) {
  use ast.Parsed(node: inputs, tokens:, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use ast.Parsed(node: outputs, tokens:, ..) <- result.try(
    parse_outputs(source, tokens, []),
  )
  use ast.Parsed(node: expressions, tokens:, ..) as body <- result.try(
    parse_body(source, tokens, []),
  )

  let span = source.Span(start: start, end: body.span.end)

  Ok(ast.Parsed(
    node: ast.Operation(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      expressions: list.reverse(expressions),
    ),
    span:,
    tokens:,
  ))
}

fn parse_nested(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
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

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_nested(source, remaining)
    }
  }
}

fn parse_nested_equal(
  source: String,
  name: ast.Parsed(String),
) -> Result(ast.Parsed(ast.Expression), diagnostic.Diagnostic) {
  case name.tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> {
      use tokens <- result.try(parse_nonstarter.parse(source, rest))
      let assert [token.Token(span:, ..), ..] = tokens
      use operation <- result.try(parse_operation(source, tokens, span.start))

      let span = source.Span(start: name.span.start, end: operation.span.end)

      Ok(ast.Parsed(
        node: ast.Binding(span:, name: name.node, value: operation.node),
        span:,
        tokens: operation.tokens,
      ))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, name.tokens))

      parse_nested_equal(
        source,
        ast.Parsed(node: name.node, span: name.span, tokens:),
      )
    }
  }
}

fn parse_inputs(
  source: String,
  tokens: List(token.Token),
  inputs: List(ast.Parameter),
) -> Result(ast.Parsed(List(ast.Parameter)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use ast.Parsed(node: parameter, tokens: remaining, ..) <- result.try(
        parse_parameter.parse(source, tokens),
      )

      parse_inputs(source, remaining, [parameter, ..inputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_inputs(source, rest, inputs)

    [token.Token(kind: token.RArrow, span:), ..rest] ->
      Ok(ast.Parsed(node: inputs, span:, tokens: rest))

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_inputs(source, remaining, inputs)
    }
  }
}

fn parse_outputs(
  source: String,
  tokens: List(token.Token),
  outputs: List(ast.Parameter),
) -> Result(ast.Parsed(List(ast.Parameter)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use ast.Parsed(node: parameter, tokens: remaining, ..) <- result.try(
        parse_parameter.parse(source, tokens),
      )

      parse_outputs(source, remaining, [parameter, ..outputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_outputs(source, rest, outputs)

    [token.Token(kind: token.LBrace, span:), ..] ->
      Ok(ast.Parsed(node: outputs, span:, tokens:))

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_outputs(source, remaining, outputs)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(token.Token),
  expressions: List(ast.Expression),
) -> Result(ast.Parsed(List(ast.Expression)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LBrace, ..), ..rest] ->
      parse_body(source, rest, expressions)

    [token.Token(kind: token.RBrace, span: r_brace_span), ..rest] ->
      Ok(ast.Parsed(node: expressions, span: r_brace_span, tokens: rest))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use ast.Parsed(node: expression, tokens: remaining, ..) <- result.try(
        parse_nested(source, tokens),
      )

      parse_body(source, remaining, [expression, ..expressions])
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use ast.Parsed(node: expression, tokens: remaining, ..) <- result.try(
        parse_expression.parse(source, tokens),
      )

      parse_body(source, remaining, [expression, ..expressions])
    }

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_body(source, remaining, expressions)
    }
  }
}
