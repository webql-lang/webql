import gleam/list
import gleam/result
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
import webql/compiler/runtime

/// Resolves an operation body and its nested declarations.
pub fn resolve(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  operation: parser_ast.Operation,
) -> Result(#(ast.Operation, runtime.Runtime), diagnostic.Diagnostic) {
  use #(operation, runtime, _environment) <- result.try(resolve_body(
    environment,
    runtime,
    operation,
  ))
  Ok(#(operation, runtime))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_body(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  operation: parser_ast.Operation,
) -> Result(
  #(ast.Operation, runtime.Runtime, environment.Environment),
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

  use #(parameters, runtime) <- result.try(resolve_parameters(
    environment,
    runtime,
    parameters,
  ))

  use #(returns, runtime) <- result.try(resolve_returns(
    environment,
    runtime,
    returns,
  ))

  use #(definitions, runtime, environment) <- result.try(resolve_definitions(
    environment,
    runtime,
    definitions,
  ))

  use #(bindings, runtime) <- result.try(resolve_bindings(
    environment,
    runtime,
    bindings,
  ))

  use #(edges, runtime) <- result.try(resolve_edges(environment, runtime, edges))

  Ok(#(
    ast.Operation(parameters:, returns:, definitions:, bindings:, edges:, span:),
    runtime,
    environment,
  ))
}

fn resolve_parameters(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  parameters: List(parser_ast.Parameter),
) {
  case parameters {
    [parameter, ..rest] -> {
      let reference = runtime.next_parameter(runtime)

      use parameter <- result.try(resolve_parameter.resolve(
        environment,
        runtime,
        parameter,
        reference,
      ))

      let runtime = register_parameter.register(runtime, parameter)

      use #(rest, runtime) <- result.try(resolve_parameters(
        environment,
        runtime,
        rest,
      ))
      Ok(#([parameter, ..rest], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_returns(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  returns: List(parser_ast.Return),
) {
  case returns {
    [return, ..rest] -> {
      let reference = runtime.next_return(runtime)

      use return <- result.try(resolve_return.resolve(
        environment,
        runtime,
        return,
        reference,
      ))

      let runtime = register_return.register(runtime, return)

      use #(rest, runtime) <- result.try(resolve_returns(
        environment,
        runtime,
        rest,
      ))
      Ok(#([return, ..rest], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_definitions(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  definitions: List(parser_ast.Definition),
) -> Result(
  #(List(ast.Definition), runtime.Runtime, environment.Environment),
  diagnostic.Diagnostic,
) {
  case definitions {
    [definition, ..definitions] -> {
      let reference = runtime.next_definition(runtime)

      use #(definition, sub_runtime) <- result.try(resolve_definition.resolve(
        environment,
        runtime,
        definition,
        reference,
        resolve,
      ))

      let runtime =
        register_definiton.register(runtime, definition, sub_runtime)

      let environment = register_definition_node(environment, definition)

      use #(definitions, runtime, environment) <- result.try(
        resolve_definitions(environment, runtime, definitions),
      )

      Ok(#([definition, ..definitions], runtime, environment))
    }

    [] -> Ok(#([], runtime, environment))
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
  runtime: runtime.Runtime,
  bindings: List(parser_ast.Binding),
) {
  case bindings {
    [binding, ..bindings] -> {
      let reference = runtime.next_binding(runtime)

      use binding <- result.try(resolve_binding.resolve(
        environment,
        runtime,
        binding,
        reference,
      ))

      let runtime = register_binding.register(environment, runtime, binding)

      use #(bindings, runtime) <- result.try(resolve_bindings(
        environment,
        runtime,
        bindings,
      ))

      Ok(#([binding, ..bindings], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_edges(
  environment: environment.Environment,
  runtime: runtime.Runtime,
  edges: List(parser_ast.Edge),
) {
  case edges {
    [edge, ..edges] -> {
      let reference = runtime.next_edge(runtime)
      use edge <- result.try(resolve_edge.resolve(
        environment,
        runtime,
        edge,
        reference,
      ))

      let runtime = register_edge.register(runtime, edge)

      use #(edges, runtime) <- result.try(resolve_edges(
        environment,
        runtime,
        edges,
      ))
      Ok(#([edge, ..edges], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}
