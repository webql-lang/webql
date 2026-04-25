import gleam/result
import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_edge

/// Typechecks a resolved module against its runtime.
pub fn typecheck(
  module: ast.Module,
  runtime: runtime.Runtime,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  use _ok <- result.try(typecheck_operation(runtime, module.operation))
  Ok(module)
}

// PRIVATE FUNCTIONS
// =================
fn typecheck_operation(runtime: runtime.Runtime, operation: ast.Operation) {
  use _ok <- result.try(typecheck_definitions(runtime, operation.definitions))
  typecheck_edges(runtime, operation.edges)
}

fn typecheck_definitions(
  runtime: runtime.Runtime,
  definitions: List(ast.Definition),
) {
  case definitions {
    [definition, ..rest] -> {
      let ast.Definition(reference:, operation:, ..) = definition
      let assert Ok(nested_runtime) = runtime.get_runtime(runtime, reference)

      use _ok <- result.try(typecheck_operation(nested_runtime, operation))
      typecheck_definitions(runtime, rest)
    }

    [] -> Ok(Nil)
  }
}

fn typecheck_edges(runtime: runtime.Runtime, edges: List(ast.Edge)) {
  case edges {
    [edge, ..rest] -> {
      use _ok <- result.try(typecheck_edge.typecheck(edge, runtime))
      typecheck_edges(runtime, rest)
    }

    [] -> Ok(Nil)
  }
}
