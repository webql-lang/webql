import gleam/result
import webql/compiler/parser/ast as parser_ast
import webql/compiler/resolver/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/registry
import webql/compiler/resolver/resolve_binding
import webql/compiler/resolver/resolve_definition
import webql/compiler/resolver/resolve_edge
import webql/compiler/resolver/resolve_parameter
import webql/compiler/resolver/resolve_return

/// Resolves an operation body and its nested declarations.
pub fn resolve(
  registry: registry.Registry,
  operation: parser_ast.Operation,
) -> Result(ast.Operation, diagnostic.Diagnostic) {
  use #(operation, _registry) <- result.try(resolve_body(registry, operation))
  Ok(operation)
}

// PRIVATE FUNCTIONS
// =================
fn resolve_body(registry: registry.Registry, operation: parser_ast.Operation) {
  let parser_ast.Operation(
    parameters:,
    returns:,
    definitions:,
    bindings:,
    edges:,
    span:,
  ) = operation

  use #(parameters, registry) <- result.try(resolve_parameters(
    registry,
    parameters,
  ))

  use #(returns, registry) <- result.try(resolve_returns(registry, returns))

  use #(definitions, registry) <- result.try(resolve_definitions(
    registry,
    definitions,
  ))

  use #(bindings, registry) <- result.try(resolve_bindings(registry, bindings))
  use #(edges, registry) <- result.try(resolve_edges(registry, edges))

  Ok(#(
    ast.Operation(parameters:, returns:, definitions:, bindings:, edges:, span:),
    registry,
  ))
}

fn resolve_parameters(
  registry: registry.Registry,
  parameters: List(parser_ast.Parameter),
) {
  case parameters {
    [parameter, ..rest] -> {
      let reference = registry.next_parameter(registry)

      use parameter <- result.try(resolve_parameter.resolve(
        registry,
        parameter,
        reference,
      ))

      let registry =
        registry
        |> registry.add_parameter([parameter.name])
        |> registry.add_output([parameter.name])

      use #(rest, registry) <- result.try(resolve_parameters(registry, rest))
      Ok(#([parameter, ..rest], registry))
    }

    [] -> Ok(#([], registry))
  }
}

fn resolve_returns(
  registry: registry.Registry,
  returns: List(parser_ast.Return),
) {
  case returns {
    [return, ..rest] -> {
      let reference = registry.next_return(registry)

      use return <- result.try(resolve_return.resolve(
        registry,
        return,
        reference,
      ))

      let registry =
        registry
        |> registry.add_return([return.name])
        |> registry.add_input([return.name])

      use #(rest, registry) <- result.try(resolve_returns(registry, rest))
      Ok(#([return, ..rest], registry))
    }

    [] -> Ok(#([], registry))
  }
}

fn resolve_definitions(
  registry: registry.Registry,
  definitions: List(parser_ast.Definition),
) {
  case definitions {
    [definition, ..definitions] -> {
      let reference = registry.next_definition(registry)

      use #(definition, sub_registry) <- result.try(resolve_definition.resolve(
        registry,
        definition,
        reference,
        resolve,
      ))

      let registry =
        registry.add_definition(registry, definition.name, sub_registry)

      use #(definitions, registry) <- result.try(resolve_definitions(
        registry,
        definitions,
      ))

      Ok(#([definition, ..definitions], registry))
    }

    [] -> Ok(#([], registry))
  }
}

fn resolve_bindings(
  registry: registry.Registry,
  bindings: List(parser_ast.Binding),
) {
  case bindings {
    [binding, ..bindings] -> {
      let reference = registry.next_binding(registry)

      use binding <- result.try(resolve_binding.resolve(
        registry,
        binding,
        reference,
      ))

      let registry = registry.add_binding(registry, [binding.name])

      use #(bindings, registry) <- result.try(resolve_bindings(
        registry,
        bindings,
      ))

      Ok(#([binding, ..bindings], registry))
    }

    [] -> Ok(#([], registry))
  }
}

fn resolve_edges(registry: registry.Registry, edges: List(parser_ast.Edge)) {
  case edges {
    [edge, ..edges] -> {
      let reference = registry.next_edge(registry)
      use edge <- result.try(resolve_edge.resolve(registry, edge, reference))

      let registry = registry.add_edge(registry, edge.to.reference)

      use #(edges, registry) <- result.try(resolve_edges(registry, edges))
      Ok(#([edge, ..edges], registry))
    }

    [] -> Ok(#([], registry))
  }
}
