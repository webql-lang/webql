import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_source
import webql/compiler/resolver/resolve_target

/// Resolves an edge declaration.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  edge: parser.Edge,
  reference: reference.Edge,
) -> Result(hir.Edge, diagnostic.Diagnostic) {
  let parser.Edge(source:, target:, span:) = edge

  use source <- result.try(resolve_source.resolve(environment, context, source))
  use target <- result.try(resolve_target.resolve(context, target))

  use <- bool.guard(
    when: result.is_ok(context.get_edge(context, target.reference)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdgeInput(target.path),
      span:,
    )),
  )

  Ok(hir.Edge(source:, target:, reference:, span:))
}
