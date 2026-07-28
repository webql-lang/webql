import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_edge
import webql/compiler/resolver/register_parameter
import webql/compiler/resolver/register_return
import webql/compiler/resolver/resolve_edge
import webql/compiler/resolver/resolve_node
import webql/compiler/resolver/resolve_parameter
import webql/compiler/resolver/resolve_return

/// Resolves a graph body and its nested declarations.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  graph: parser.Graph,
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
  graph: parser.Graph,
) -> Result(
  #(hir.Graph, context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  let parser.Graph(parameters:, returns:, nodes:, edges:, span:) = graph

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
  parameters: List(parser.Parameter),
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
  returns: List(parser.Return),
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
  nodes: List(parser.Node),
) -> Result(
  #(List(hir.Node), context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  case nodes {
    [parser.Supernode(..) as supernode, ..nodes] -> {
      use #(supernode, context, environment) <- result.try(resolve_node.resolve(
        environment,
        context,
        supernode,
        resolve,
      ))

      use #(nodes, context, environment) <- result.try(resolve_supernodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([supernode, ..nodes], context, environment))
    }

    [parser.Node(..), ..nodes] ->
      resolve_supernodes(environment, context, nodes)

    [] -> Ok(#([], context, environment))
  }
}

fn resolve_nodes(
  environment: environment.Environment,
  context: context.Context,
  nodes: List(parser.Node),
) {
  case nodes {
    [parser.Node(..) as node, ..nodes] -> {
      use #(node, context, _environment) <- result.try(resolve_node.resolve(
        environment,
        context,
        node,
        resolve,
      ))

      use #(nodes, context) <- result.try(resolve_nodes(
        environment,
        context,
        nodes,
      ))

      Ok(#([node, ..nodes], context))
    }

    [parser.Supernode(..), ..nodes] ->
      resolve_nodes(environment, context, nodes)

    [] -> Ok(#([], context))
  }
}

fn resolve_edges(
  environment: environment.Environment,
  context: context.Context,
  edges: List(parser.Edge),
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
