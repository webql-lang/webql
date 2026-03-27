import gleam/result
import gleam/string
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_nonstarter

/// Parses annotations in a field.
pub fn parse(
  source: String,
  tokens: List(token.Token),
) -> Result(#(ast.Annotation, List(token.Token)), diagnostic.Diagnostic) {
  case tokens {
    [token.Token(kind: token.UpperIdentifier, ..) as token, ..rest] ->
      Ok(#(parse_named_type_annotation(source, token), rest))

    _token -> {
      use tokens <- result.try(parse_nonstarter.parse(source, tokens))
      parse(source, tokens)
    }
  }
}

fn parse_named_type_annotation(source: String, token: token.Token) {
  let name =
    string.slice(
      from: source,
      at_index: token.span.start,
      length: token.span.end - token.span.start,
    )

  ast.NamedTypeAnnotation(name)
}
