import gleam/dict
import gleam/option
import webql/lang/parser/ast as parser_ast
import webql/lang/resolver/ast
import webql/lang/resolver/diagnostic
import webql/lang/resolver/reference
import webql/lang/resolver/registry
import webql/lang/resolver/resolve_value
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

    parser_ast.Literal(value:, ..) -> resolve_value.resolve(registry, value)

    parser_ast.Access(path:, span:) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name: case path {
          [name, ..] -> name
          [] -> ""
        }),
        span:,
      ))

    parser_ast.Node(name:, span:) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name:),
        span:,
      ))

    parser_ast.Operation(span:, ..) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name: ""),
        span:,
      ))
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

    parser_ast.Literal(value:, ..) -> resolve_value.resolve(registry, value)

    parser_ast.Access(path:, span:) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name: case path {
          [name, ..] -> name
          [] -> ""
        }),
        span:,
      ))

    parser_ast.Node(name:, span:) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name:),
        span:,
      ))

    parser_ast.Operation(span:, ..) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownReference(owner: option.None, name: ""),
        span:,
      ))
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
