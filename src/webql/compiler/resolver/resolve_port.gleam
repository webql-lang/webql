import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir

/// Resolves ports in a field.
pub fn resolve(
  environment: environment.Environment,
  port: parser.Port,
) -> Result(hir.Port, diagnostic.Diagnostic) {
  case environment.get_port(environment, port.name) {
    Ok(reference) -> Ok(hir.Port(name: port.name, reference:, span: port.span))

    Error(_nil) ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.UnknownPort(port.name),
        span: port.span,
      ))
  }
}
