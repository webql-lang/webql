import gleam/dict
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_primitive
import webql/lang/source

const int = "Int"

const float = "Float"

const string = "String"

/// Resolves a reference.
pub fn resolve_input(
  registry: registry.Registry,
  input: parser_ast.Input,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  let parser_ast.PortInput(path:, span:) = input
  resolve_input_access(registry, path, span)
}

pub fn resolve_output(
  registry: registry.Registry,
  output: parser_ast.Output,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case output {
    parser_ast.PortOutput(path:, span:) ->
      resolve_output_access(registry, path, span)
    parser_ast.PrimitiveOutput(value:, span:) ->
      resolve_literal(registry, value, span)
  }
}

pub fn resolve_value(
  registry: registry.Registry,
  value: parser_ast.Value,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case value {
    parser_ast.NodeValue(name:, span:) -> resolve_node(registry, name, span)
    parser_ast.PrimitiveValue(value:, span:) ->
      resolve_literal(registry, value, span)
  }
}

pub fn resolve_definition(
  registry: registry.Registry,
  definition: parser_ast.Definition,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  let parser_ast.Definition(name:, operation:, span:) = definition
  resolve_operation(registry, name, operation, span)
}

// PRIVATE FUNCTIONS
// =================
fn resolve_input_access(
  registry: registry.Registry,
  path: List(String),
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(registry.inputs, path) {
    Ok(reference) -> Ok(ast.InputAccess(path:, reference:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path:), span:))
  }
}

fn resolve_output_access(
  registry: registry.Registry,
  path: List(String),
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(registry.outputs, path) {
    Ok(reference) -> Ok(ast.OutputAccess(path:, reference:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path:), span:))
  }
}

fn resolve_node(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(registry.nodes, name) {
    Ok(reference) -> Ok(ast.Node(name:, reference:, span:))
    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))
  }
}

fn resolve_operation(
  registry: registry.Registry,
  name: String,
  operation: parser_ast.Operation,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(registry.operations, name) {
    Ok(#(reference, _registry)) ->
      Ok(ast.SubOperation(
        name:,
        reference:,
        operation: ast.Operation(
          inputs: [],
          outputs: [],
          bindings: [],
          edges: [],
          span: operation.span,
        ),
        span:,
      ))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownOperation(name),
        span:,
      ))
  }
}

fn resolve_literal(
  registry: registry.Registry,
  value: parser_ast.Primitive,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  use reference <- result.try(case value {
    parser_ast.Int(..) -> resolve_typename(registry, int, span)
    parser_ast.Float(..) -> resolve_typename(registry, float, span)
    parser_ast.String(..) -> resolve_typename(registry, string, span)
  })

  Ok(ast.Literal(value: resolve_primitive.resolve(value), reference:, span:))
}

fn resolve_typename(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(reference.Typename, diagnostic.Diagnostic) {
  case dict.get(registry.typenames, name) {
    Ok(reference) -> Ok(reference)
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownTypename(name), span:))
  }
}
