import gleam/result
import webql/compiler/lexer/token
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses a typename annotation in a parameter.
///
/// ## Examples
///
///     String
///     Int
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(
  #(ast.Typename, source.Span, List(token.Token)),
  diagnostic.Diagnostic,
) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      Ok(#(ast.Typename(span:, name:), span, rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}
