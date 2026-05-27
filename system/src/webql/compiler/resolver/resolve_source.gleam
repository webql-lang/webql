import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser/ast
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_value
import webql/compiler/source

/// Resolves an edge source.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  source: ast.Source,
) -> Result(hir.Source, diagnostic.Diagnostic) {
  case source {
    ast.Output(path:, span:) -> resolve_output(context, path, span)

    ast.Literal(value:, span:) -> resolve_literal(environment, value, span)
  }
}

// PRIVATE FUNCTIONS
// =================
fn resolve_output(
  context: context.Context,
  path: List(String),
  span: source.Span,
) {
  case context.get_output(context, path) {
    Ok(#(reference, _)) -> Ok(hir.Output(path:, reference:, span:))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}

fn resolve_literal(
  environment: environment.Environment,
  value: ast.Value,
  span: source.Span,
) {
  case environment.get_port(environment, value.name) {
    Ok(port) -> {
      let value = resolve_value.resolve(value)
      Ok(hir.Literal(value:, port:, span:))
    }

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownPort(value.name),
        span:,
      ))
  }
}
