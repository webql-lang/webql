import webql/compiler/context
import webql/compiler/resolver/hir
import webql/compiler/typechecker/diagnostic

/// Typechecks a resolved edge.
pub fn typecheck(
  edge: hir.Edge,
  context: context.Context,
) -> Result(Nil, diagnostic.Diagnostic) {
  let hir.Edge(source:, target:, span:, ..) = edge
  let expected = get_port_target(context, target)
  let found = get_port_source(context, source)

  case expected, found {
    expected, found if expected == found -> Ok(Nil)
    _, _ ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.TypeMismatch(expected:, found:),
        span:,
      ))
  }
}

// PRIVATE FUNCTIONS
// =================
fn get_port_source(context: context.Context, source: hir.Source) {
  case source {
    hir.Output(path:, ..) -> {
      let assert Ok(#(_reference, port)) = context.get_output(context, path)
      port
    }

    hir.Static(port:, ..) -> port
  }
}

fn get_port_target(context: context.Context, target: hir.Target) {
  let hir.Input(path:, ..) = target
  let assert Ok(#(_reference, port)) = context.get_input(context, path)
  port
}
