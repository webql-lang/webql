import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/runtime

/// Resolves an edge input.
pub fn resolve(
  runtime: runtime.Runtime,
  input: parser_ast.Input,
) -> Result(ast.Input, diagnostic.Diagnostic) {
  let parser_ast.PortInput(path:, span:) = input

  case runtime.get_input(runtime, path) {
    Ok(#(reference, _typename)) -> Ok(ast.PortInput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}
