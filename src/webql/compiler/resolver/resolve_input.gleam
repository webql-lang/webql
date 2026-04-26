import webql/compiler/context
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic

/// Resolves an edge input.
pub fn resolve(
  context: context.Context,
  input: parser_ast.Input,
) -> Result(ast.Input, diagnostic.Diagnostic) {
  let parser_ast.PortInput(path:, span:) = input

  case context.get_input(context, path) {
    Ok(#(reference, _typename)) -> Ok(ast.PortInput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}
