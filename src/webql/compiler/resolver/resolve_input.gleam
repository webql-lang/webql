import webql/compiler/context
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

/// Resolves an edge input.
pub fn resolve(
  context: context.Context,
  input: ast.Input,
) -> Result(hir.Input, diagnostic.Diagnostic) {
  let ast.PortInput(path:, span:) = input

  case context.get_input(context, path) {
    Ok(#(reference, _typename)) -> Ok(hir.PortInput(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}
