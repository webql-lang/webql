import gleam/dict
import gleam/option
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_value
import webql/lang/source

/// Resolves a input reference.
pub fn resolve_input(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.NodePortReference(alias:, port:, span:) ->
      resolve_node_port_reference(
        registry.environment.inputs,
        alias,
        port,
        span,
      )

    parser_ast.OperationPortReference(port:, span:) ->
      resolve_operation_port_reference(registry.environment.inputs, port, span)

    parser_ast.ValueReference(value:, ..) ->
      resolve_value.resolve(registry, value)
  }
}

/// Resolves a output reference.
pub fn resolve_output(
  registry: registry.Registry,
  reference: parser_ast.Reference,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case reference {
    parser_ast.NodePortReference(alias:, port:, span:) ->
      resolve_node_port_reference(
        registry.environment.outputs,
        alias,
        port,
        span,
      )

    parser_ast.OperationPortReference(port:, span:) ->
      resolve_operation_port_reference(registry.environment.outputs, port, span)

    parser_ast.ValueReference(value:, ..) ->
      resolve_value.resolve(registry, value)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_node_port_reference(
  environment: dict.Dict(#(option.Option(String), String), reference.Port),
  alias: String,
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(environment, #(option.Some(alias), name)) {
    Ok(port) -> Ok(ast.NodePortReference(alias:, port:, name:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.Some(alias), name:),
        span:,
      ))
  }
}

fn resolve_operation_port_reference(
  environment: dict.Dict(#(option.Option(String), String), reference.Port),
  name: String,
  span: source.Span,
) -> Result(ast.Reference, diagnostic.Diagnostic) {
  case dict.get(environment, #(option.None, name)) {
    Ok(port) -> Ok(ast.OperationPortReference(port:, name:, span:))

    Error(_missing) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name:),
        span:,
      ))
  }
}
