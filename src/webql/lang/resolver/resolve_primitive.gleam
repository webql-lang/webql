import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/source

const int = "Int"

const float = "Float"

const string = "String"

/// Resolves a value and associates primatives with types.
pub fn resolve(
  registry: registry.Registry,
  value: parser_ast.Primitive,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case value {
    parser_ast.Int(value:, span:) -> {
      use reference <- result.try(resolve_typename(registry, int, span))
      Ok(ast.Literal(value: ast.Int(value:, span:), reference:, span:))
    }

    parser_ast.Float(value:, span:) -> {
      use reference <- result.try(resolve_typename(registry, float, span))
      Ok(ast.Literal(value: ast.Float(value:, span:), reference:, span:))
    }

    parser_ast.String(value:, span:) -> {
      use reference <- result.try(resolve_typename(registry, string, span))
      Ok(ast.Literal(value: ast.String(value:, span:), reference:, span:))
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_typename(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(reference.Typename, diagnostic.Diagnostic) {
  case dict.get(registry.catalog.typenames, name) {
    Ok(typename) -> Ok(typename)
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
