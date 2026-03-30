import gleam/result
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter
import webql/lang/source

/// Parses annotations in a field.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(ast.Parsed(ast.Annotation), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      Ok(ast.Parsed(
        node: ast.NamedTypeAnnotation(span:, name:),
        span:,
        tokens: rest,
      ))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}
