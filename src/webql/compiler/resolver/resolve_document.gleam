import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_graph

/// Resolves a top-level document.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  document: parser.Document,
  reference: reference.Document,
) -> Result(#(hir.Document, context.Context), diagnostic.Diagnostic) {
  use #(graph, context) <- result.try(resolve_graph.resolve(
    environment,
    context,
    document.graph,
  ))

  Ok(#(hir.Document(graph:, reference:, span: document.span), context))
}
