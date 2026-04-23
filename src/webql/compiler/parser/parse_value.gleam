import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_primitive
import webql/compiler/source

/// Parses a binding value.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Value, source.Span, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] ->
      Ok(#(ast.NodeValue(name: source.slice(source, span), span:), span, rest))

    [token.Token(kind: token.Int, ..), ..]
    | [token.Token(kind: token.Float, ..), ..]
    | [token.Token(kind: token.String, ..), ..] ->
      parse_primitive_value(source, tokens)

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_primitive_value(source: String, tokens: List(token.Token)) {
  use #(value, span, rest) <- result.try(parse_primitive.parse(source, tokens))

  Ok(#(ast.PrimitiveValue(value:, span:), span, rest))
}
