import gleam/bool
import gleam/result
import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_port

/// Resolves an output field.
pub fn resolve(
  environment: environment.Environment,
  context: context.Context,
  field: parser.Return,
  reference: reference.Return,
) -> Result(hir.Return, diagnostic.Diagnostic) {
  let parser.Return(name:, port:, span:) = field

  use <- bool.guard(
    when: result.is_ok(context.get_return(context, name)),
    return: Error(diagnostic.Diagnostic(
      kind: diagnostic.DuplicateReturn(name),
      span:,
    )),
  )

  use port <- result.try(resolve_port.resolve(environment, port))

  Ok(hir.Return(name:, port:, reference:, span:))
}
