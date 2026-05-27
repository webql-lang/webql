import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_edge
import webql/compiler/resolver/register_node
import webql/compiler/resolver/register_parameter
import webql/compiler/resolver/register_return
import webql/compiler/resolver/register_supernode
import webql/compiler/resolver/resolve_edge
import webql/compiler/resolver/resolve_node
import webql/compiler/resolver/resolve_parameter
import webql/compiler/resolver/resolve_return
import webql/compiler/resolver/resolve_supernode

/// Resolves a graph body and its nested declarations.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  graph: ast.Graph,
) -> Result(#(hir.Graph, context.Context), diagnostic.Diagnostic) {
  use #(graph, context, _environment) <- result.try(resolve_body(
    environment,
    context,
    graph,
  ))
  Ok(#(graph, context))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_body(
  environment: environment.Environment,
  context: context.Context,
  graph: ast.Graph,
) -> Result(
  #(hir.Graph, context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  let ast.Graph(parameters:, returns:, nodes:, edges:, span:) = graph

  use #(parameters, context) <- result.try(resolve_parameters(
    environment,
    context,
    parameters,
  ))

  use #(returns, context) <- result.try(resolve_returns(
    environment,
    context,
    returns,
  ))

  use #(supernodes, context, environment) <- result.try(resolve_supernodes(
    environment,
    context,
    nodes,
  ))

  use #(nodes, context) <- result.try(resolve_nodes(environment, context, nodes))

  use #(edges, context) <- result.try(resolve_edges(environment, context, edges))

  let nodes = list.append(supernodes, nodes)

  Ok(#(
    hir.Graph(parameters:, returns:, nodes:, edges:, span:),
    context,
    environment,
  ))
}

fn resolve_parameters(
  environment: environment.Environment,
  context: context.Context,
  parameters: List(ast.Parameter),
) {
  case parameters {
    [parameter, ..rest] -> {
      let reference = context.next_parameter(context)

      use parameter <- result.try(resolve_parameter.resolve(
        environment,
        context,
        parameter,
        reference,
      ))

      let context = register_parameter.register(context, parameter)

      use #(rest, context) <- result.try(resolve_parameters(
        environment,
        context,
        rest,
      ))
      Ok(#([parameter, ..rest], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_returns(
  environment: environment.Environment,
  context: context.Context,
  returns: List(ast.Return),
) {
  case returns {
    [return, ..rest] -> {
      let reference = context.next_return(context)

      use return <- result.try(resolve_return.resolve(
        environment,
        context,
        return,
        reference,
      ))

      let context = register_return.register(context, return)

      use #(rest, context) <- result.try(resolve_returns(
        environment,
        context,
        rest,
      ))
      Ok(#([return, ..rest], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_supernodes(
  environment: environment.Environment,
  context: context.Context,
  nodes: List(ast.Node),
) -> Result(
  #(List(hir.Node), context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  case nodes {
    [ast.Supernode(..) as supernode, ..nodes] -> {
      let reference = context.next_supernode(context)

      use #(supernode, sub_context) <- result.try(resolve_supernode.resolve(
        environment,
        context,
        supernode,
        reference,
        resolve,
      ))

      let context = register_supernode.register(context, supernode, sub_context)

      let environment = register_supernode_operation(environment, supernode)

      use #(nodes, context, environment) <- result.try(resolve_supernodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([supernode, ..nodes], context, environment))
    }

    [ast.Node(..), ..nodes] -> resolve_supernodes(environment, context, nodes)

    [] -> Ok(#([], context, environment))
  }
}

fn register_supernode_operation(
  environment: environment.Environment,
  supernode: hir.Node,
) -> environment.Environment {
  let assert hir.Supernode(name:, graph:, ..) = supernode

  let environment = environment.add_operation(environment, name)
  let assert Ok(operation) = environment.get_operation(environment, name)

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

fn resolve_nodes(
  environment: environment.Environment,
  context: context.Context,
  nodes: List(ast.Node),
) {
  case nodes {
    [ast.Node(..) as node, ..nodes] -> {
      let reference = context.next_node(context)

      use node <- result.try(resolve_node.resolve(
        environment,
        context,
        node,
        reference,
      ))

      let context = register_node.register(environment, context, node)

      use #(nodes, context) <- result.try(resolve_nodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([node, ..nodes], context))
    }

    [ast.Supernode(..), ..nodes] -> resolve_nodes(environment, context, nodes)

    [] -> Ok(#([], context))
  }
}

fn resolve_edges(
  environment: environment.Environment,
  context: context.Context,
  edges: List(ast.Edge),
) {
  case edges {
    [edge, ..edges] -> {
      let reference = context.next_edge(context)
      use edge <- result.try(resolve_edge.resolve(
        environment,
        context,
        edge,
        reference,
      ))

      let context = register_edge.register(context, edge)

      use #(edges, context) <- result.try(resolve_edges(
        environment,
        context,
        edges,
      ))
      Ok(#([edge, ..edges], context))
    }

    [] -> Ok(#([], context))
  }
}
