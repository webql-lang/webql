import gleam/result
import webql/compiler/context
import webql/compiler/resolver/hir
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

/// Typechecks a resolved document against its context.
pub fn typecheck(
  document: hir.Document,
  context: context.Context,
) -> Result(hir.Document, diagnostic.Diagnostic) {
  use _ok <- result.try(typecheck_graph(context, document.graph))
  Ok(document)
}

// PRIVATE FUNCTIONS
// =================
fn typecheck_graph(context: context.Context, graph: hir.Graph) {
  use _ok <- result.try(typecheck_supernodes(context, graph.nodes))
  typecheck_edges(context, graph.edges)
}

fn typecheck_supernodes(context: context.Context, nodes: List(hir.Node)) {
  case nodes {
    [hir.Supernode(reference:, graph:, span:, ..), ..rest] -> {
      use nested_context <- result.try(get_context(context, reference, span))

      use _ok <- result.try(typecheck_graph(nested_context, graph))
      typecheck_supernodes(context, rest)
    }

    [hir.Node(..), ..rest] -> typecheck_supernodes(context, rest)

    [] -> Ok(Nil)
  }
}

fn get_context(context: context.Context, reference, span) {
  case context.get_context(context, reference) {
    Ok(context) -> Ok(context)
    Error(_error) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownSupernode(reference),
        span:,
      ))
  }
}

fn typecheck_edges(context: context.Context, edges: List(hir.Edge)) {
  case edges {
    [edge, ..rest] -> {
      use _ok <- result.try(typecheck_edge.typecheck(edge, context))
      typecheck_edges(context, rest)
    }

    [] -> Ok(Nil)
  }
}
