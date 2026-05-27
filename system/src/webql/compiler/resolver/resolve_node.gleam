import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

/// Resolves a node declaration.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  node: ast.Node,
  reference: reference.Node,
) -> Result(hir.Node, diagnostic.Diagnostic) {
  let assert ast.Node(name:, node:, span:) = node

  use <- bool.guard(
    when: result.is_ok(context.get_node(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateNode(name),
      span:,
    )),
  )

  case environment.get_operation(environment, node) {
    Ok(operation) -> Ok(hir.Node(name:, node:, operation:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(node), span:))
  }
}
