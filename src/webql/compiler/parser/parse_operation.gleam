import gleam/list
import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/cursor
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_binding
import webql/compiler/parser/parse_definition
import webql/compiler/parser/parse_edge
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_parameter
import webql/compiler/parser/parse_return
import webql/compiler/source

/// Parses an operation.
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
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_operation(source: String, tokens: List(token.Token), start: Int) {
  use cursor.Cursor(current: parameters, rest:, ..) <- result.try(
    parse_parameters(source, tokens, []),
  )

  use cursor.Cursor(current: returns, rest:, ..) <- result.try(
    parse_returns(source, rest, []),
  )

  use cursor.Cursor(current: #(definitions, bindings, edges), rest:, span:) <- result.try(
    parse_body(source, rest, [], [], []),
  )

  let span = source.Span(start: start, end: span.end)

  Ok(cursor.Cursor(
    current: ast.Operation(
      parameters: list.reverse(parameters),
      returns: list.reverse(returns),
      definitions: list.reverse(definitions),
      bindings: list.reverse(bindings),
      edges: list.reverse(edges),
      span:,
    ),
    span:,
    rest:,
  ))
}

fn parse_parameters(
  source: String,
  tokens: List(token.Token),
  parameters: List(ast.Parameter),
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: parameter, rest:, ..) <- result.try(
        parse_parameter.parse(source, tokens),
      )

      parse_parameters(source, rest, [parameter, ..parameters])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_parameters(source, rest, parameters)

    [token.Token(kind: token.RArrow, span:), ..rest] ->
      Ok(cursor.Cursor(current: parameters, span:, rest:))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_parameters(source, rest, parameters)
    }
  }
}

fn parse_returns(
  source: String,
  tokens: List(token.Token),
  returns: List(ast.Return),
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..] -> {
      use cursor.Cursor(current: return, rest:, ..) <- result.try(
        parse_return.parse(source, tokens),
      )

      parse_returns(source, rest, [return, ..returns])
    }

    [token.Token(kind: token.Comma, ..), ..rest] ->
      parse_returns(source, rest, returns)

    [token.Token(kind: token.LBrace, span:), ..] ->
      Ok(cursor.Cursor(current: returns, span:, rest: tokens))

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_returns(source, rest, returns)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(token.Token),
  definitions: List(ast.Definition),
  bindings: List(ast.Binding),
  edges: List(ast.Edge),
) {
  use tokens <- result.try(parse_left_brace(source, tokens))
  parse_block_body(source, tokens, definitions, bindings, edges)
}

fn parse_left_brace(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.LBrace, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_left_brace(source, rest)
    }
  }
}

fn parse_block_body(
  source: String,
  tokens: List(token.Token),
  definitions: List(ast.Definition),
  bindings: List(ast.Binding),
  edges: List(ast.Edge),
) {
  case tokens {
    [token.Token(kind: token.RBrace, span:), ..rest] ->
      Ok(cursor.Cursor(current: #(definitions, bindings, edges), span:, rest:))

    [token.Token(kind: token.UpperIdentifier, ..), ..] -> {
      use cursor.Cursor(current: definition, rest:, ..) <- result.try(
        parse_definition.parse(source, tokens, parse),
      )

      parse_block_body(
        source,
        rest,
        [definition, ..definitions],
        bindings,
        edges,
      )
    }

    [token.Token(kind: token.LowerIdentifier, ..), ..] ->
      parse_lower_block_body(source, tokens, definitions, bindings, edges)

    [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] -> {
      use cursor.Cursor(current: edge, rest:, ..) <- result.try(
        parse_edge.parse(source, tokens),
      )

      parse_block_body(source, rest, definitions, bindings, [edge, ..edges])
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_block_body(source, rest, definitions, bindings, edges)
    }
  }
}

fn parse_lower_block_body(
  source: String,
  tokens: List(token.Token),
  definitions: List(ast.Definition),
  bindings: List(ast.Binding),
  edges: List(ast.Edge),
) {
  case tokens {
    [
      token.Token(kind: token.LowerIdentifier, ..),
      token.Token(kind: token.Equal, ..),
      ..
    ] -> {
      use cursor.Cursor(current: binding, rest:, ..) <- result.try(
        parse_binding.parse(source, tokens),
      )

      parse_block_body(source, rest, definitions, [binding, ..bindings], edges)
    }

    [
      token.Token(kind: token.LowerIdentifier, ..),
      token.Token(kind: token.Dot, ..),
      ..
    ] -> {
      use cursor.Cursor(current: edge, rest:, ..) <- result.try(
        parse_edge.parse(source, tokens),
      )

      parse_block_body(source, rest, definitions, bindings, [edge, ..edges])
    }

    [token.Token(kind: token.LowerIdentifier, ..) as identifier, ..rest] -> {
      use rest <- result.try(parse_nonstarter.parse(source, rest))

      parse_lower_block_body(
        source,
        [identifier, ..rest],
        definitions,
        bindings,
        edges,
      )
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_block_body(source, rest, definitions, bindings, edges)
    }
  }
}
