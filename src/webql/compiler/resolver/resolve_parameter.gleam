import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_port

/// Resolves an input field.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  field: parser.Parameter,
  reference: reference.Parameter,
) -> Result(hir.Parameter, diagnostic.Diagnostic) {
  let parser.Parameter(name:, port:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_parameter(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateParameter(name),
      span:,
    )),
  )

  use port <- result.try(resolve_port.resolve(environment, port))

  Ok(hir.Parameter(name:, port:, reference:, span:))
}
