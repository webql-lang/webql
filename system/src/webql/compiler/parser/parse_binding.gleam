import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_value
import webql/compiler/source

/// Parses a binding inside an operation body.
///
/// ## Examples
///
///     m = Math
///     value = "hello world"
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Binding, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)
      parse_binding_name(source, name)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, rest)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_binding_name(
  source: String,
  name: #(String, source.Span, List(token.Token)),
) {
  let #(name, name_span, rest) = name
  use rest <- result.try(parse_equal(source, rest))
  use #(value, value_span, rest) <- result.try(parse_value.parse(source, rest))

  let span = source.cover(name_span, value_span)

  Ok(#(ast.Binding(name:, value:, span:), span, rest))
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
