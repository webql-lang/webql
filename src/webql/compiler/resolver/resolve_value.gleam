import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/source

/// Resolves a binding value.
pub fn resolve(
  environment: environment.Environment,
  value: ast.Value,
) -> Result(hir.Value, diagnostic.Diagnostic) {
  case value {
    ast.NodeValue(name:, span:) -> resolve_node_value(environment, name, span)
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
    Ok(reference) -> Ok(hir.NodeValue(name:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))
  }
}
