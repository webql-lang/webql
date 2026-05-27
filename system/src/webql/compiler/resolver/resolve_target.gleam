import webql/compiler/context
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

/// Resolves an edge target.
pub fn resolve(
  context: context.Context,
  target: ast.Target,
) -> Result(hir.Target, diagnostic.Diagnostic) {
  let ast.Input(path:, span:) = target

  case context.get_input(context, path) {
    Ok(#(reference, _port)) -> Ok(hir.Input(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}
