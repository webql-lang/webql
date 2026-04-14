import gleam/dict
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_primitive
import webql/lang/source

/// Resolves an input reference.
pub fn resolve_input(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.Access(path: [alias, port], span:) ->
      resolve_node_port_reference(
        registry.environment.inputs,
        alias,
        port,
        span,
      )

    parser_ast.Access(path: [port], span:) ->
      resolve_operation_port_reference(registry.environment.inputs, port, span)

    parser_ast.Literal(value:, ..) -> resolve_primitive.resolve(registry, value)

    parser_ast.Access(path:, span:) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownAccess(path:), span:))

    parser_ast.Node(name:, span:) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))

    parser_ast.SubOperation(name:, span:, ..) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperation(name), span:))
  }
}

/// Resolves an output reference.
pub fn resolve_output(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.Access(path: [alias, port], span:) ->
      resolve_node_port_reference(
        registry.environment.outputs,
        alias,
        port,
        span,
      )

    parser_ast.Access(path: [port], span:) ->
      resolve_operation_port_reference(registry.environment.outputs, port, span)

    parser_ast.Literal(value:, ..) -> resolve_primitive.resolve(registry, value)

    parser_ast.Access(path:, span:) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownAccess(path:), span:))

    parser_ast.Node(name:, span:) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(name), span:))

    parser_ast.SubOperation(name:, span:, ..) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperation(name), span:))
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_port_reference(
  environment: dict.Dict(List(String), reference.Access),
  alias: String,
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(environment, [alias, name]) {
    Ok(reference) -> Ok(ast.Access(path: [alias, name], reference:, span:))

    Error(_missing) ->
      Error(
        diagnostic.Diagnostic(
          kind: diagnostic.UnknownAccess(path: [alias, name]),
          span:,
        )
      )
  }
}

fn resolve_operation_port_reference(
  environment: dict.Dict(List(String), reference.Access),
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(environment, [name]) {
    Ok(reference) -> Ok(ast.Access(path: [name], reference:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownAccess([name]), span:))
  }
}
