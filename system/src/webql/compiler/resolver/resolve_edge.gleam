import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_input
import webql/compiler/resolver/resolve_output

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
