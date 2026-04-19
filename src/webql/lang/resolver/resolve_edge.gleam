import gleam/bool
import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_input
import webql/lang/resolver/resolve_output

/// Resolves an edge declaration.
pub fn resolve(
  registry: registry.Registry,
  edge: parser_ast.Edge,
  reference: reference.Edge,
) -> Result(ast.Edge, diagnostic.Diagnostic) {
  let parser_ast.Edge(from:, to:, span:) = edge

  use from <- result.try(resolve_output.resolve(registry, from))
  use to <- result.try(resolve_input.resolve(registry, to))

  case from, to {
    ast.PortOutput(..), ast.PortInput(..) -> {
      use <- bool.guard(
        when: dict.has_key(registry.edges, #(from.reference, to.reference)),
        return: Error(diagnostic.Diagnostic(
          kind: diagnostic.DuplicateEdge(#(from.reference, to.reference)),
          span:,
        )),
      )

      Ok(ast.Edge(from:, to:, reference:, span:))
    }

    ast.PrimitiveOutput(..), ast.PortInput(..) -> {
      Ok(ast.Edge(from:, to:, reference:, span:))
    }
  }
}
