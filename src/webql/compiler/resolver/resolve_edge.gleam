import gleam/bool
import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/resolve_input
import webql/compiler/resolver/resolve_output
import webql/compiler/runtime
import webql/loader/schema

/// Resolves an edge declaration.
pub fn resolve(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  edge: parser_ast.Edge,
  reference: reference.Edge,
) -> Result(ast.Edge, diagnostic.Diagnostic) {
  let parser_ast.Edge(from:, to:, span:) = edge

  use from <- result.try(resolve_output.resolve(schema, runtime, from))
  use to <- result.try(resolve_input.resolve(runtime, to))

  use <- bool.guard(
    when: result.is_ok(runtime.get_edge(runtime, to.reference)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateEdge(to.reference),
      span:,
    )),
  )

  Ok(ast.Edge(from:, to:, reference:, span:))
}
