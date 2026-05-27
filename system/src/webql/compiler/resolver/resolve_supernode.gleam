import gleam/bool
import gleam/dict
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

/// Resolves a nested graph supernode.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  supernode: ast.Node,
  reference: reference.Supernode,
  resolve_graph,
) -> Result(#(hir.Node, context.Context), diagnostic.Diagnostic) {
  let assert ast.Supernode(name:, graph:, span:) = supernode

  use <- bool.guard(
    when: result.is_ok(environment.get_operation(environment, supernode.name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateSupernode(supernode.name),
      span: supernode.span,
    )),
  )

  let context =
    context.Context(
      ..context,
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      nodes: dict.new(),
      edges: dict.new(),
    )

  use #(graph, context) <- result.try(resolve_graph(environment, context, graph))

  Ok(#(hir.Supernode(name:, graph:, reference:, span:), context))
}
