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
  value: parser_ast.Primative,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case value {
    parser_ast.Int(value:, span:) -> {
      use typename <- result.try(resolve_type(registry, int, span))

      Ok(ast.ValueReference(
        value: ast.IntValue(value:, span:),
        typename:,
        span:,
      ))
    }

    parser_ast.Float(value:, span:) -> {
      use typename <- result.try(resolve_type(registry, float, span))

      Ok(ast.ValueReference(
        value: ast.FloatValue(value:, span:),
        typename:,
        span:,
      ))
    }

    parser_ast.String(value:, span:) -> {
      use typename <- result.try(resolve_type(registry, string, span))

      Ok(ast.ValueReference(
        value: ast.StringValue(value:, span:),
        typename:,
        span:,
      ))
    }
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_type(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(reference.Type, diagnostic.Diagnostic) {
  case dict.get(registry.catalog.typenames, name) {
    Ok(typename) -> Ok(typename)
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownType(name), span:))
  }
}
