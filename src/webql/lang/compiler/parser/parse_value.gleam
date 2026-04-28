import gleam/result
import webql/lang/compiler/lexer/token
import webql/lang/compiler/parser/ast
import webql/lang/compiler/parser/diagnostic
import webql/lang/compiler/parser/parse_nonstarter
import webql/lang/compiler/source

/// Parses a binding value.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Value, source.Span, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] ->
      Ok(#(ast.NodeValue(name: source.slice(source, span), span:), span, rest))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}
