import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_primitive
import webql/compiler/source

/// Resolves a binding value.
pub fn resolve(
  environment: environment.Environment,
  value: parser_ast.Value,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case value {
    parser_ast.NodeValue(name:, span:) ->
      resolve_node_value(environment, name, span)

    parser_ast.PrimitiveValue(value:, span:) ->
      resolve_primitive_value(environment, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_value(
  environment: environment.Environment,
  name: String,
  span: source.Span,
) {
  case environment.get_node(environment, name) {
    Ok(reference) -> Ok(ast.NodeValue(name:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))
  }
}

fn resolve_primitive_value(
  environment: environment.Environment,
  value: parser_ast.Primitive,
  span: source.Span,
) {
  case environment.get_typename(environment, value.name) {
    Ok(typename) -> {
      let value = resolve_primitive.resolve(value)
      Ok(ast.PrimitiveValue(value:, typename:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownTypename(value.name),
        span:,
      ))
  }
}
