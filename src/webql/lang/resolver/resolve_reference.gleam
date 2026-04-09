import gleam/dict
import gleam/option
import gleam/result
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_value
import webql/lang/source

/// Resolves a reference in an output/read position.
pub fn resolve(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.NodePortReference(alias:, port:, span:) ->
      resolve_node_port_reference(registry, alias, port, span)

    parser_ast.OperationPortReference(port:, span:) ->
      resolve_operation_port_reference(registry, port, span)

    parser_ast.ValueReference(value:, ..) ->
      resolve_value.resolve(registry, value)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_port_reference(
  registry: registry.Registry,
  alias: String,
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  use node <- result.try(case dict.get(registry.environment.nodes, alias) {
    Ok(node) -> Ok(node)
    Error(_missing) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(alias:), span:))
  })

  case dict.get(registry.environment.outputs, #(option.Some(alias), name)) {
    Ok(port) -> Ok(ast.NodePortReference(node:, alias:, port:, name:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownPort(owner: option.Some(alias), name:),
        span:,
      ))
  }
}

fn resolve_operation_port_reference(
  registry: registry.Registry,
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(registry.environment.outputs, #(option.None, name)) {
    Ok(port) -> Ok(ast.OperationPortReference(port:, name:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownPort(owner: option.None, name:),
        span:,
      ))
  }
}
