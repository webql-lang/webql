import gleam/list
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/typechecker/diagnostic
import webql/compiler/typechecker/typecheck_module
import webql/loader/schema

pub opaque type Typechecker {
  Typechecker(module: ast.Module)
}

/// Creates a new resolver instance from a parser module.
pub fn new(module: ast.Module) -> Typechecker {
  Typechecker(module:)
}

/// Resolves a resolver instance.
pub fn resolve(
  typechecker: Typechecker,
  schema: schema.Schema,
) -> Result(ast.Module, diagnostic.Diagnostic) {
  let runtime = build_runtime(typechecker.module, schema)
  typecheck_module.typecheck(typechecker.module, runtime)
}

fn build_runtime(module: ast.Module, schema: schema.Schema) -> runtime.Runtime {
  build_operation_runtime(module.operation, schema)
}

fn build_operation_runtime(
  operation: ast.Operation,
  schema: schema.Schema,
) -> runtime.Runtime {
  let schema = register_definition_nodes(schema, operation.definitions)

  runtime.new()
  |> register_parameters(operation.parameters)
  |> register_returns(operation.returns)
  |> register_definitions(operation.definitions, schema)
  |> register_bindings(operation.bindings, schema)
}

fn register_parameters(
  runtime: runtime.Runtime,
  parameters: List(ast.Parameter),
) -> runtime.Runtime {
  list.fold(parameters, runtime, fn(runtime, parameter) {
    runtime
    |> runtime.add_parameter(parameter.name)
    |> runtime.add_output([parameter.name], parameter.typename.reference)
  })
}

fn register_returns(
  runtime: runtime.Runtime,
  returns: List(ast.Return),
) -> runtime.Runtime {
  list.fold(returns, runtime, fn(runtime, return) {
    runtime
    |> runtime.add_return(return.name)
    |> runtime.add_input([return.name], return.typename.reference)
  })
}

fn register_definitions(
  runtime: runtime.Runtime,
  definitions: List(ast.Definition),
  schema: schema.Schema,
) -> runtime.Runtime {
  list.fold(definitions, runtime, fn(runtime, definition) {
    let nested_runtime = build_operation_runtime(definition.operation, schema)

    runtime
    |> runtime.add_definition(definition.name)
    |> runtime.add_runtime(definition.reference, nested_runtime)
  })
}

fn register_bindings(
  runtime: runtime.Runtime,
  bindings: List(ast.Binding),
  schema: schema.Schema,
) -> runtime.Runtime {
  list.fold(bindings, runtime, fn(runtime, binding) {
    let runtime = runtime.add_binding(runtime, binding.name)

    case binding.value {
      ast.NodeValue(reference: node, ..) ->
        runtime
        |> register_node_inputs(binding.name, node, schema)
        |> register_node_outputs(binding.name, node, schema)

      ast.PrimitiveValue(..) -> runtime
    }
  })
}

fn register_definition_nodes(
  schema: schema.Schema,
  definitions: List(ast.Definition),
) -> schema.Schema {
  list.fold(definitions, schema, fn(schema, definition) {
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
  })
}

fn register_node_inputs(
  runtime: runtime.Runtime,
  binding: String,
  node: reference.Node,
  schema: schema.Schema,
) -> runtime.Runtime {
  case schema.get_inputs(schema, node) {
    Ok(inputs) ->
      list.fold(inputs, runtime, fn(runtime, input) {
        let #(port, typename) = input
        runtime.add_input(runtime, [binding, port], typename)
      })

    Error(_nil) -> runtime
  }
}

fn register_node_outputs(
  runtime: runtime.Runtime,
  binding: String,
  node: reference.Node,
  schema: schema.Schema,
) -> runtime.Runtime {
  case schema.get_outputs(schema, node) {
    Ok(outputs) ->
      list.fold(outputs, runtime, fn(runtime, output) {
        let #(port, typename) = output
        runtime.add_output(runtime, [binding, port], typename)
      })

    Error(_nil) -> runtime
  }
}
