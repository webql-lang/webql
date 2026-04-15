import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_primitive
import webql/lang/source

const int = "Int"

const float = "Float"

const string = "String"

/// Resolves an input reference.
pub fn resolve_input(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  resolve_reference(registry.environment.inputs, registry, reference)
}

/// Resolves an output reference.
pub fn resolve_output(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  resolve_reference(registry.environment.outputs, registry, reference)
}

// PRIVATE FUNCTIONS
// =================
fn resolve_reference(
  environment: dict.Dict(List(String), reference.Access),
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.Access(path:, span:) -> resolve_access(environment, path, span)
    parser_ast.Literal(value:, span:) -> resolve_literal(registry, value, span)

    parser_ast.Node(name:, span:) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))

    parser_ast.SubOperation(name:, span:, ..) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownOperation(name),
        span:,
      ))
  }
}

fn resolve_access(
  environment: dict.Dict(List(String), reference.Access),
  path: List(String),
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(environment, path) {
    Ok(reference) -> Ok(ast.Access(path:, reference:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownAccess(path:), span:))
  }
}

fn resolve_literal(
  registry: registry.Registry,
  value: parser_ast.Primitive,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  use reference <- result.try(case value {
    parser_ast.Int(..) -> resolve_typename(registry, int, span)
    parser_ast.Float(..) -> resolve_typename(registry, float, span)
    parser_ast.String(..) -> resolve_typename(registry, string, span)
  })

  Ok(ast.Literal(value: resolve_primitive.resolve(value), reference:, span:))
}

fn resolve_typename(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(reference.Typename, diagnostic.Diagnostic) {
  case dict.get(registry.catalog.typenames, name) {
    Ok(reference) -> Ok(reference)
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
