import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/primative
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_primitive
import webql/lang/source

/// Resolves an edge output.
pub fn resolve(
  registry: registry.Registry,
  output: parser_ast.Output,
) -> Result(ast.Output, diagnostic.Diagnostic) {
  case output {
    parser_ast.PortOutput(path:, span:) ->
      resolve_port_output(registry, path, span)

    parser_ast.PrimitiveOutput(value:, span:) ->
      resolve_primitive_output(registry, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_port_output(
  registry: registry.Registry,
  path: List(String),
  span: source.Span,
) {
  case dict.get(registry.outputs, path) {
    Ok(reference) -> Ok(ast.PortOutput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_primitive_output(
  registry: registry.Registry,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  use typename <- result.try(resolve_primitive_typename(registry, value, span))
  let value = resolve_primitive.resolve(value)

  Ok(ast.PrimitiveOutput(value:, typename:, span:))
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
