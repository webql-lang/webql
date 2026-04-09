import gleam/dict
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/registry
import webql/lang/source

/// Resolves annotations in a field.
pub fn resolve(
  registry: registry.Registry,
  annotation: parser_ast.Annotation,
) -> Result(ast.Annotation, diagnostic.Diagnostic) {
  case annotation {
    parser_ast.NamedTypeAnnotation(name:, span:) ->
      resolve_named_type_annotation(registry, name, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_named_type_annotation(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) {
  case dict.get(registry.catalog.typenames, name) {
    Ok(typename) -> Ok(ast.NamedTypeAnnotation(typename:, name:, span:))
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownType(name), span:))
  }
}
