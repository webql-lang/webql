import gleam/list
import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_expression
import webql/lang/parser/parse_field
import webql/lang/parser/parse_nonstarter

/// Parses an operation.
///
/// ## Examples
///
///     .in -> .out { ... }
///     -> .out { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Operation, List(token.Token)), diagnostic.Diagnostic) {
  use #(inputs, tokens) <- result.try(parse_inputs(source, tokens, []))
  use #(outputs, tokens) <- result.try(parse_outputs(source, tokens, []))
  use #(body, tokens) <- result.try(parse_body(source, tokens, #([], [])))

  let #(operations, expressions) = body

  Ok(#(
    ast.Operation(
      inputs: list.reverse(inputs),
      outputs: list.reverse(outputs),
      operations: list.reverse(operations),
      expressions: list.reverse(expressions),
    ),
    tokens,
  ))
}

fn parse_nested(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Operation, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span: span), ..rest] -> {
      let name =
        string.slice(
          from: source,
          at_index: span.start,
          length: span.end - span.start,
        )

      parse_nested_equal(source, rest, name)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_nested(source, rest)
    }
  }
}

fn parse_nested_equal(
  source: String,
  tokens: List(token.Token),
  name: String,
) -> Result(#(ast.Operation, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> {
      use #(operation, rest) <- result.try(parse(source, rest))

      case operation {
        ast.Operation(inputs:, outputs:, operations:, expressions:) ->
          Ok(#(
            ast.NestedOperation(
              name: name,
              inputs: inputs,
              outputs: outputs,
              operations: operations,
              expressions: expressions,
            ),
            rest,
          ))

        ast.NestedOperation(..) -> Ok(#(operation, rest))
      }
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_nested_equal(source, rest, name)
    }
  }
}

fn parse_inputs(
  source: String,
  tokens: List(token.Token),
  inputs: List(ast.Field),
) -> Result(#(List(ast.Field), List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use #(field, rest) <- result.try(parse_field.parse(source, tokens))
      parse_inputs(source, rest, [field, ..inputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_inputs(source, rest, inputs)

    [token.Token(kind: token.RArrow, ..), ..rest] -> Ok(#(inputs, rest))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_inputs(source, rest, inputs)
    }
  }
}

fn parse_outputs(
  source: String,
  tokens: List(token.Token),
  outputs: List(ast.Field),
) -> Result(#(List(ast.Field), List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use #(field, rest) <- result.try(parse_field.parse(source, tokens))
      parse_outputs(source, rest, [field, ..outputs])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_outputs(source, rest, outputs)

    [token.Token(kind: token.LBrace, ..), ..rest] -> Ok(#(outputs, rest))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_outputs(source, rest, outputs)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(token.Token),
  body: #(List(ast.Operation), List(ast.Expression)),
) -> Result(
  #(#(List(ast.Operation), List(ast.Expression)), List(token.Token)),
  diagnostic.Diagnostic,
) {
  let #(operations, expressions) = body

  case tokens {
    [token.Token(kind: token.RBrace, ..), ..rest] -> Ok(#(body, rest))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use #(operation, rest) <- result.try(parse_nested(source, tokens))

      parse_body(source, rest, #([operation, ..operations], expressions))
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use #(expression, rest) <- result.try(parse_expression.parse(
        source,
        tokens,
      ))

      parse_body(source, rest, #(operations, [expression, ..expressions]))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_body(source, rest, body)
    }
  }
}
