import gleam/bool
import gleam/result
import webql/lang/compiler/context
import webql/lang/compiler/environment
import webql/lang/compiler/hir
import webql/lang/compiler/parser/ast
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/diagnostic
import webql/lang/compiler/resolver/resolve_input
import webql/lang/compiler/resolver/resolve_output

/// Resolves an edge declaration.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  edge: ast.Edge,
  reference: reference.Edge,
) -> Result(hir.Edge, diagnostic.Diagnostic) {
  let ast.Edge(from:, to:, span:) = edge

  use from <- result.try(resolve_output.resolve(environment, context, from))
  use to <- result.try(resolve_input.resolve(context, to))

  use <- bool.guard(
    when: result.is_ok(context.get_edge(context, to.reference)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(to.path),
      span:,
    )),
  )

  Ok(hir.Edge(from:, to:, reference:, span:))
}
