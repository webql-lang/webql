import gleam/result
import webql/compiler/context
import webql/compiler/resolver/hir
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

/// Typechecks a resolved module against its context.
pub fn typecheck(
  module: hir.Module,
  context: context.Context,
) -> Result(hir.Module, diagnostic.Diagnostic) {
  use _ok <- result.try(typecheck_operation(context, module.operation))
  Ok(module)
}

// PRIVATE FUNCTIONS
// =================
fn typecheck_operation(context: context.Context, operation: hir.Operation) {
  use _ok <- result.try(typecheck_definitions(context, operation.definitions))
  typecheck_edges(context, operation.edges)
}

fn typecheck_definitions(
  context: context.Context,
  definitions: List(hir.Definition),
) {
  case definitions {
    [definition, ..rest] -> {
      let hir.Definition(reference:, operation:, ..) = definition
      let assert Ok(nested_context) = context.get_context(context, reference)

      use _ok <- result.try(typecheck_operation(nested_context, operation))
      typecheck_definitions(context, rest)
    }

    [] -> Ok(Nil)
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
