import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_node
import webql/compiler/resolver/register_supernode

/// Resolves a node declaration.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  node: ast.Node,
  resolve_graph,
) -> Result(
  #(hir.Node, context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  case node {
    ast.Node(name:, node:, span:) ->
      resolve_node(environment, context, name, node, span)

    ast.Supernode(name:, graph:, span:) ->
      resolve_supernode(environment, context, name, graph, span, resolve_graph)
  }
}

fn resolve_node(
  environment: environment.Environment,
  context: context.Context,
  name: String,
  node: String,
  span,
) {
  use <- bool.guard(
    when: result.is_ok(context.get_node(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateNode(name),
      span:,
    )),
  )

  case environment.get_operation(environment, node) {
    Ok(operation) -> {
      let reference = context.next_node(context)
      let node = hir.Node(name:, node:, operation:, reference:, span:)
      let context = register_node.register(environment, context, node)

      Ok(#(node, context, environment))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(node), span:))
  }
}

fn resolve_supernode(
  environment: environment.Environment,
  context: context.Context,
  name: String,
  graph: ast.Graph,
  span,
  resolve_graph,
) {
  use <- bool.guard(
    when: result.is_ok(environment.get_operation(environment, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateSupernode(name),
      span:,
    )),
  )

  let reference = context.next_supernode(context)

  use #(graph, sub_context) <- result.try(resolve_graph(
    environment,
    context.Context(
      ..context,
      parameters: dict.new(),
      returns: dict.new(),
      inputs: dict.new(),
      outputs: dict.new(),
      nodes: dict.new(),
      edges: dict.new(),
    ),
    graph,
  ))

  let supernode = hir.Supernode(name:, graph:, reference:, span:)
  let context =
    register_supernode.register(context, name, reference, sub_context)
  let environment = register_supernode_operation(environment, name, graph)

  Ok(#(supernode, context, environment))
}

fn register_supernode_operation(
  environment: environment.Environment,
  name: String,
  graph: hir.Graph,
) -> environment.Environment {
  let operation = environment.next_operation(environment)
  let environment = environment.add_operation(environment, name)

  let environment =
    list.fold(graph.parameters, environment, fn(environment, parameter) {
      environment.add_input(environment, operation, #(
        parameter.name,
        parameter.port.reference,
      ))
    })

  list.fold(graph.returns, environment, fn(environment, return) {
    environment.add_output(environment, operation, #(
      return.name,
      return.port.reference,
    ))
  })
}
