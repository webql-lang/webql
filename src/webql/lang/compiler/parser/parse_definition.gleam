import gleam/result
import webql/lang/compiler/lexer/token
import webql/lang/compiler/parser/ast
import webql/lang/compiler/parser/diagnostic
import webql/lang/compiler/parser/parse_nonstarter
import webql/lang/compiler/source

/// Parses a nested operation definition.
pub fn parse(
  source: String,
  tokens: List(token.Token),
  parse_operation: fn(String, List(token.Token)) ->
    Result(
      #(ast.Operation, source.Span, List(token.Token)),
      diagnostic.Diagnostic,
    ),
) -> Result(
  #(ast.Definition, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)

      parse_definition_name(source, name, parse_operation)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest, parse_operation)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_definition_name(
  source: String,
  name: #(String, source.Span, List(token.Token)),
  parse_operation: fn(String, List(token.Token)) ->
    Result(
      #(ast.Operation, source.Span, List(token.Token)),
      diagnostic.Diagnostic,
    ),
) {
  let #(name, name_span, rest) = name
  use rest <- result.try(parse_equal(source, rest))
  use #(operation, operation_span, rest) <- result.try(parse_operation(
    source,
    rest,
  ))

  let span = source.Span(start: name_span.start, end: operation_span.end)

  Ok(#(ast.Definition(name:, operation:, span:), span, rest))
}

fn parse_equal(source: String, tokens: List(token.Token)) {
  case tokens {
    [token.Token(kind: token.Equal, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse_equal(source, rest)
    }
  }
}
