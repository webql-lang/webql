import gleam/list
import gleam/result
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
import webql/loader/schema

/// Resolves an operation body and its nested declarations.
pub fn resolve(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  operation: parser_ast.Operation,
) -> Result(ast.Operation, diagnostic.Diagnostic) {
  use #(operation, _runtime) <- result.try(resolve_with_runtime(
    schema,
    runtime,
    operation,
  ))
  Ok(operation)
}

/// Resolves an operation body and returns its populated runtime.
pub fn resolve_with_runtime(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  operation: parser_ast.Operation,
) -> Result(#(ast.Operation, runtime.Runtime), diagnostic.Diagnostic) {
  use #(operation, runtime, _schema) <- result.try(resolve_body(
    schema,
    runtime,
    operation,
  ))
  Ok(#(operation, runtime))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_body(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  operation: parser_ast.Operation,
) -> Result(
  #(ast.Operation, runtime.Runtime, schema.Schema),
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
    schema,
    runtime,
    parameters,
  ))

  use #(returns, runtime) <- result.try(resolve_returns(
    schema,
    runtime,
    returns,
  ))

  use #(definitions, runtime, schema) <- result.try(resolve_definitions(
    schema,
    runtime,
    definitions,
  ))

  use #(bindings, runtime) <- result.try(resolve_bindings(
    schema,
    runtime,
    bindings,
  ))

  use #(edges, runtime) <- result.try(resolve_edges(schema, runtime, edges))

  Ok(#(
    ast.Operation(parameters:, returns:, definitions:, bindings:, edges:, span:),
    runtime,
    schema,
  ))
}

fn resolve_parameters(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  parameters: List(parser_ast.Parameter),
) {
  case parameters {
    [parameter, ..rest] -> {
      let reference = runtime.next_parameter(runtime)

      use parameter <- result.try(resolve_parameter.resolve(
        schema,
        runtime,
        parameter,
        reference,
      ))

      let runtime = register_parameter.register(runtime, parameter)

      use #(rest, runtime) <- result.try(resolve_parameters(
        schema,
        runtime,
        rest,
      ))
      Ok(#([parameter, ..rest], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_returns(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  returns: List(parser_ast.Return),
) {
  case returns {
    [return, ..rest] -> {
      let reference = runtime.next_return(runtime)

      use return <- result.try(resolve_return.resolve(
        schema,
        runtime,
        return,
        reference,
      ))

      let runtime = register_return.register(runtime, return)

      use #(rest, runtime) <- result.try(resolve_returns(schema, runtime, rest))
      Ok(#([return, ..rest], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_definitions(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  definitions: List(parser_ast.Definition),
) -> Result(
  #(List(ast.Definition), runtime.Runtime, schema.Schema),
  diagnostic.Diagnostic,
) {
  case definitions {
    [definition, ..definitions] -> {
      let reference = runtime.next_definition(runtime)

      use #(definition, sub_runtime) <- result.try(resolve_definition.resolve(
        schema,
        runtime,
        definition,
        reference,
        resolve_with_runtime,
      ))

      let runtime =
        register_definiton.register(runtime, definition, sub_runtime)

      let schema = register_definition_node(schema, definition)

      use #(definitions, runtime, schema) <- result.try(resolve_definitions(
        schema,
        runtime,
        definitions,
      ))

      Ok(#([definition, ..definitions], runtime, schema))
    }

    [] -> Ok(#([], runtime, schema))
  }
}

fn register_definition_node(
  schema: schema.Schema,
  definition: ast.Definition,
) -> schema.Schema {
  let schema = schema.add_node(schema, definition.name)
  let assert Ok(node) = schema.get_node(schema, definition.name)

  let schema =
    list.fold(definition.operation.parameters, schema, fn(schema, parameter) {
      schema.add_input(schema, node, #(
        parameter.name,
        parameter.typename.reference,
      ))
    })

  list.fold(definition.operation.returns, schema, fn(schema, return) {
    schema.add_output(schema, node, #(return.name, return.typename.reference))
  })
}

fn resolve_bindings(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  bindings: List(parser_ast.Binding),
) {
  case bindings {
    [binding, ..bindings] -> {
      let reference = runtime.next_binding(runtime)

      use binding <- result.try(resolve_binding.resolve(
        schema,
        runtime,
        binding,
        reference,
      ))

      let runtime = register_binding.register(schema, runtime, binding)

      use #(bindings, runtime) <- result.try(resolve_bindings(
        schema,
        runtime,
        bindings,
      ))

      Ok(#([binding, ..bindings], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}

fn resolve_edges(
  schema: schema.Schema,
  runtime: runtime.Runtime,
  edges: List(parser_ast.Edge),
) {
  case edges {
    [edge, ..edges] -> {
      let reference = runtime.next_edge(runtime)
      use edge <- result.try(resolve_edge.resolve(
        schema,
        runtime,
        edge,
        reference,
      ))

      let runtime = register_edge.register(runtime, edge)

      use #(edges, runtime) <- result.try(resolve_edges(schema, runtime, edges))
      Ok(#([edge, ..edges], runtime))
    }

    [] -> Ok(#([], runtime))
  }
}
