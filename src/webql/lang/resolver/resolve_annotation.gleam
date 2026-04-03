import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
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
    parser_ast.ListTypeAnnotation(of:, span:) ->
      resolve_list_type_annotation(registry, of, span)
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

fn resolve_list_type_annotation(
  registry: registry.Registry,
  of: parser_ast.Annotation,
  span: source.Span,
) {
  case of {
    parser_ast.NamedTypeAnnotation(name:, ..) as named_type_annotation -> {
      use of <- result.try(resolve_named_type_annotation(
        registry,
        name,
        named_type_annotation.span,
      ))

      use typename <- result.try(
        case dict.get(registry.catalog.typenames, name) {
          Ok(reference) -> Ok(reference)
          Error(_not_found) ->
            Error(diagnostic.Diagnostic(
              kind: diagnostic.UnknownType(name:),
              span: named_type_annotation.span,
            ))
        },
      )

      Ok(ast.ListTypeAnnotation(
        typename: reference.ListType(typename),
        span:,
        of:,
      ))
    }

    parser_ast.ListTypeAnnotation(of:, ..) as list_type_annotation -> {
      use of <- result.try(resolve_list_type_annotation(
        registry,
        of,
        list_type_annotation.span,
      ))

      let typename = case of {
        ast.ListTypeAnnotation(typename, ..) -> typename
        ast.NamedTypeAnnotation(typename, ..) -> typename
      }

      Ok(ast.ListTypeAnnotation(
        typename: reference.ListType(typename),
        span:,
        of:,
      ))
    }
  }
}
