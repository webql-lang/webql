import gleam/list
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/register_binding
import webql/compiler/resolver/register_definiton
import webql/compiler/resolver/register_edge
import webql/compiler/resolver/register_parameter
import webql/compiler/resolver/register_return
import webql/compiler/resolver/resolve_binding
import webql/compiler/resolver/resolve_definition
import webql/compiler/resolver/resolve_edge
import webql/compiler/resolver/resolve_parameter
import webql/compiler/resolver/resolve_return

/// Resolves an operation body and its nested declarations.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  operation: parser_ast.Operation,
) -> Result(#(ast.Operation, context.Context), diagnostic.Diagnostic) {
  use #(operation, context, _environment) <- result.try(resolve_body(
    environment,
    context,
    operation,
  ))
  Ok(#(operation, context))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_body(
  environment: environment.Environment,
  context: context.Context,
  operation: parser_ast.Operation,
) -> Result(
  #(ast.Operation, context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  let parser_ast.Operation(
    parameters:,
    returns:,
    definitions:,
    bindings:,
    edges:,
    span:,
  ) = operation

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

  use #(definitions, context, environment) <- result.try(resolve_definitions(
    environment,
    context,
    definitions,
  ))

  use #(bindings, context) <- result.try(resolve_bindings(
    environment,
    context,
    bindings,
  ))

  use #(edges, context) <- result.try(resolve_edges(environment, context, edges))

  Ok(#(
    ast.Operation(parameters:, returns:, definitions:, bindings:, edges:, span:),
    context,
    environment,
  ))
}

fn resolve_parameters(
  environment: environment.Environment,
  context: context.Context,
  parameters: List(parser_ast.Parameter),
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
  returns: List(parser_ast.Return),
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

fn resolve_definitions(
  environment: environment.Environment,
  context: context.Context,
  definitions: List(parser_ast.Definition),
) -> Result(
  #(List(ast.Definition), context.Context, environment.Environment),
  diagnostic.Diagnostic,
) {
  case definitions {
    [definition, ..definitions] -> {
      let reference = context.next_definition(context)

      use #(definition, sub_context) <- result.try(resolve_definition.resolve(
        environment,
        context,
        definition,
        reference,
        resolve,
      ))

      let context =
        register_definiton.register(context, definition, sub_context)

      let environment = register_definition_node(environment, definition)

      use #(definitions, context, environment) <- result.try(
        resolve_definitions(environment, context, definitions),
      )

      Ok(#([definition, ..definitions], context, environment))
    }

    [] -> Ok(#([], context, environment))
  }
}

fn register_definition_node(
  environment: environment.Environment,
  definition: ast.Definition,
) -> environment.Environment {
  let environment = environment.add_node(environment, definition.name)
  let assert Ok(node) = environment.get_node(environment, definition.name)

  let environment =
    list.fold(
      definition.operation.parameters,
      environment,
      fn(environment, parameter) {
        environment.add_input(environment, node, #(
          parameter.name,
          parameter.typename.reference,
        ))
      },
    )

  list.fold(definition.operation.returns, environment, fn(environment, return) {
    environment.add_output(environment, node, #(
      return.name,
      return.typename.reference,
    ))
  })
}

fn resolve_bindings(
  environment: environment.Environment,
  context: context.Context,
  bindings: List(parser_ast.Binding),
) {
  case bindings {
    [binding, ..bindings] -> {
      let reference = context.next_binding(context)

      use binding <- result.try(resolve_binding.resolve(
        environment,
        context,
        binding,
        reference,
      ))

      let context = register_binding.register(environment, context, binding)

      use #(bindings, context) <- result.try(resolve_bindings(
        environment,
        context,
        bindings,
      ))

      Ok(#([binding, ..bindings], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_edges(
  environment: environment.Environment,
  context: context.Context,
  edges: List(parser_ast.Edge),
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
