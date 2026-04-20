import gleam/dict
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/primative
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_primitive
import webql/compiler/source

/// Resolves a binding value.
pub fn resolve(
  registry: registry.Registry,
  value: parser_ast.Value,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case value {
    parser_ast.NodeValue(name:, span:) ->
      resolve_node_value(registry, name, span)

    parser_ast.PrimitiveValue(value:, span:) ->
      resolve_primitive_value(registry, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_value(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) {
  case dict.get(registry.nodes, name) {
    Ok(reference) -> Ok(ast.NodeValue(name:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))
  }
}

fn resolve_primitive_value(
  registry: registry.Registry,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  use typename <- result.try(resolve_primitive_typename(registry, value, span))
  let value = resolve_primitive.resolve(value)

  Ok(ast.PrimitiveValue(value:, typename:, span:))
}

fn resolve_primitive_typename(
  registry: registry.Registry,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  let name = primative.get_typename(value)

  case dict.get(registry.typenames, name) {
    Ok(reference) -> Ok(reference)

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
