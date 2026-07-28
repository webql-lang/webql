import gleam/result
import webql/compiler/lexer
import webql/compiler/parser/ast
import webql/compiler/parser/diagnostic
import webql/compiler/parser/parse_nonstarter
import webql/compiler/source

/// Parses a port annotation in a parameter.
///
/// ## Examples
///
///     Int
///     Float
///     String
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(ast.Port, source.Span, List(lexer.Token)), diagnostic.Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.UpperIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      Ok(#(ast.Port(span:, name:), span, rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}
