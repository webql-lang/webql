import gleam/list
import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
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
) -> Result(cursor.Cursor(ast.Module), diagnostic.Diagnostic) {
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
) -> Result(cursor.Cursor(ast.Module), diagnostic.Diagnostic) {
  use cursor.Cursor(current: inputs, rest:, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use cursor.Cursor(current: outputs, rest:, ..) <- result.try(
    parse_outputs(source, rest, []),
  )
  use cursor.Cursor(current: expressions, rest:, ..) as body <- result.try(
    parse_body(source, rest, []),
  )

  let span = source.Span(start: start, end: body.span.end)

  Ok(cursor.Cursor(
    current: ast.Module(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      expressions: list.reverse(expressions),
    ),
    span:,
    rest:,
  ))
}

fn parse_operation(
  source: String,
  tokens: List(token.Token),
  start: Int,
) -> Result(cursor.Cursor(ast.Reference), diagnostic.Diagnostic) {
  use cursor.Cursor(current: inputs, rest:, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use cursor.Cursor(current: outputs, rest:, ..) <- result.try(
    parse_outputs(source, rest, []),
  )
  use cursor.Cursor(current: expressions, rest:, ..) as body <- result.try(
    parse_body(source, rest, []),
  )

  let span = source.Span(start: start, end: body.span.end)

  Ok(cursor.Cursor(
    current: ast.Operation(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      expressions: list.reverse(expressions),
    ),
    span:,
    rest:,
  ))
}

fn parse_nested(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Expression), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span: name_span), ..rest] -> {
      let name =
        cursor.Cursor(
          current: source.slice(source, name_span),
          span: name_span,
          rest:,
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
  name: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Expression), diagnostic.Diagnostic) {
  case name.rest {
    [token.Token(kind: token.Equal, ..), ..rest] -> {
      use tokens <- result.try(parse_nonstarter.parse(source, rest))
      let assert [token.Token(span:, ..), ..] = tokens
      use operation <- result.try(parse_operation(source, tokens, span.start))

      let span = source.Span(start: name.span.start, end: operation.span.end)

      Ok(cursor.Cursor(
        current: ast.Binding(
          span:,
          name: name.current,
          value: operation.current,
        ),
        span:,
        rest: operation.rest,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, name.rest))

      parse_nested_equal(
        source,
        cursor.Cursor(current: name.current, span: name.span, rest:),
      )
    }
  }
}

fn parse_inputs(
  source: String,
  tokens: List(token.Token),
  inputs: List(ast.Parameter),
) -> Result(cursor.Cursor(List(ast.Parameter)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: parameter, rest: remaining, ..) <- result.try(
        parse_parameter.parse(source, tokens),
      )

      parse_inputs(source, remaining, [parameter, ..inputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_inputs(source, rest, inputs)

    [token.Token(kind: token.RArrow, span:), ..rest] ->
      Ok(cursor.Cursor(current: inputs, span:, rest:))

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
) -> Result(cursor.Cursor(List(ast.Parameter)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: parameter, rest: remaining, ..) <- result.try(
        parse_parameter.parse(source, tokens),
      )

      parse_outputs(source, remaining, [parameter, ..outputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_outputs(source, rest, outputs)

    [token.Token(kind: token.LBrace, span:), ..] ->
      Ok(cursor.Cursor(current: outputs, span:, rest: tokens))

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
) -> Result(cursor.Cursor(List(ast.Expression)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LBrace, ..), ..rest] ->
      parse_body(source, rest, expressions)

    [token.Token(kind: token.RBrace, span: r_brace_span), ..rest] ->
      Ok(cursor.Cursor(current: expressions, span: r_brace_span, rest:))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use cursor.Cursor(current: expression, rest: remaining, ..) <- result.try(
        parse_nested(source, tokens),
      )

      parse_body(source, remaining, [expression, ..expressions])
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use cursor.Cursor(current: expression, rest: remaining, ..) <- result.try(
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
