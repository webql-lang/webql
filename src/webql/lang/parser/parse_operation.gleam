import gleam/list
import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_definition
import webql/lang/parser/parse_input
import webql/lang/parser/parse_nonstarter
import webql/lang/parser/parse_output
import webql/lang/source

/// Parses an operation.
///
/// ## Examples
///
///     x: Int -> y: Int { ... }
///     -> y: Int { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Operation), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..]
    | [token.Token(kind: token.Dot, span:), ..]
    | [token.Token(kind: token.RArrow, span:), ..] ->
      parse_operation(source, tokens, span.start)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_operation(
  source: String,
  tokens: List(token.Token),
  start: Int,
) -> Result(cursor.Cursor(ast.Operation), diagnostic.Diagnostic) {
  use cursor.Cursor(current: inputs, rest:, ..) <- result.try(
    parse_inputs(source, tokens, []),
  )
  use cursor.Cursor(current: outputs, rest:, ..) <- result.try(
    parse_outputs(source, rest, []),
  )
  use cursor.Cursor(current: definitions, rest:, ..) as body <- result.try(
    parse_body(source, rest, []),
  )

  let span = source.Span(start: start, end: body.span.end)

  Ok(cursor.Cursor(
    current: ast.Operation(
      span:,
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      definitions: list.reverse(definitions),
    ),
    span:,
    rest:,
  ))
}

fn parse_declaration(
  source: String,
  tokens: List(token.Token),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span: name_span), ..rest] -> {
      let name =
        cursor.Cursor(
          current: source.slice(source, name_span),
          span: name_span,
          rest:,
        )

      parse_declaration_equal(source, name)
    }

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_declaration(source, remaining)
    }
  }
}

fn parse_declaration_equal(
  source: String,
  name: cursor.Cursor(String),
) -> Result(cursor.Cursor(ast.Definition), diagnostic.Diagnostic) {
  case name.rest {
    [token.Token(kind: token.Equal, ..), ..rest] -> {
      use operation <- result.try(parse(source, rest))

      let span = source.Span(start: name.span.start, end: operation.span.end)

      Ok(cursor.Cursor(
        current: ast.Binding(
          span:,
          name: name.current,
          value: ast.SubOperation(
            name: name.current,
            operation: operation.current,
            span: operation.span,
          ),
        ),
        span:,
        rest: operation.rest,
      ))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, name.rest))

      parse_declaration_equal(
        source,
        cursor.Cursor(current: name.current, span: name.span, rest:),
      )
    }
  }
}

fn parse_inputs(
  source: String,
  tokens: List(token.Token),
  inputs: List(ast.Input),
) -> Result(cursor.Cursor(List(ast.Input)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: input, rest: remaining, ..) <- result.try(
        parse_input.parse(source, tokens),
      )

      parse_inputs(source, remaining, [input, ..inputs])
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
  outputs: List(ast.Output),
) -> Result(cursor.Cursor(List(ast.Output)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: output, rest: remaining, ..) <- result.try(
        parse_output.parse(source, tokens),
      )

      parse_outputs(source, remaining, [output, ..outputs])
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
  definitions: List(ast.Definition),
) -> Result(cursor.Cursor(List(ast.Definition)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LBrace, ..), ..rest] ->
      parse_body(source, rest, definitions)

    [token.Token(kind: token.RBrace, span: r_brace_span), ..rest] ->
      Ok(cursor.Cursor(current: definitions, span: r_brace_span, rest:))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use cursor.Cursor(current: definition, rest: remaining, ..) <- result.try(
        parse_declaration(source, tokens),
      )

      parse_body(source, remaining, [definition, ..definitions])
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use cursor.Cursor(current: definition, rest: remaining, ..) <- result.try(
        parse_definition.parse(source, tokens),
      )

      parse_body(source, remaining, [definition, ..definitions])
    }

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse_body(source, remaining, definitions)
    }
  }
}
