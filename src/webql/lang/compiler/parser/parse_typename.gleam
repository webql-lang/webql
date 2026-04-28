import gleam/result
import webql/lang/compiler/lexer/token
import webql/lang/compiler/parser/ast
import webql/lang/compiler/parser/diagnostic
import webql/lang/compiler/parser/parse_nonstarter
import webql/lang/compiler/source

/// Parses a typename annotation in a parameter.
///
/// ## Examples
///
///     Int
///     Float
///     String
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
