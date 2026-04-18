import gleam/dict
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/registry

/// Resolves an edge input.
pub fn resolve(
  registry: registry.Registry,
  input: parser_ast.Input,
) -> Result(ast.Input, diagnostic.Diagnostic) {
  let parser_ast.PortInput(path:, span:) = input

  case dict.get(registry.inputs, path) {
    Ok(reference) -> Ok(ast.PortInput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}
