import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/parser/parse_operation
import webql/compiler/source

/// Parses a module.
///
/// ## Examples
///
///     in: Int -> out: Int { ... }
///     -> out: Int { ... }
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Module, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.LowerIdentifier, ..), ..]
    | [token.Token(kind: token.Dot, ..), ..]
    | [token.Token(kind: token.RArrow, ..), ..] -> parse_module(source, tokens)

    _tokens -> {
      use remaining <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, remaining)
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_module(source: String, tokens: List(token.Token)) {
  use #(operation, span, rest) <- result.try(parse_operation.parse(
    source,
    tokens,
  ))

  Ok(#(ast.Module(operation:, span:), span, rest))
}
