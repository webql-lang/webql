import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/source

/// Resolves a binding value.
pub fn resolve(
  environment: environment.Environment,
  value: parser_ast.Value,
) -> Result(ast.Value, diagnostic.Diagnostic) {
  case value {
    parser_ast.NodeValue(name:, span:) ->
      resolve_node_value(environment, name, span)
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
