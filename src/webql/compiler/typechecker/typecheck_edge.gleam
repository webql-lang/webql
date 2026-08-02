import gleam/result
import webql/compiler/context
import webql/compiler/resolver
import webql/compiler/typechecker/diagnostic

/// Typechecks a resolved edge.
pub fn typecheck(
  edge: resolver.Edge,
  context: context.Context,
) -> Result(Nil, diagnostic.Diagnostic) {
  let resolver.Edge(source:, target:, span:, ..) = edge
  use expected <- result.try(get_port_target(context, target))
  use found <- result.try(get_port_source(context, source))

  case expected, found {
    expected, found if expected == found -> Ok(Nil)
    _expected, _found ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.TypeMismatch(expected:, found:),
        span:,
      ))
  }
}

// PRIVATE FUNCTIONS
// =================
fn get_port_source(context: context.Context, source: resolver.Source) {
  case source {
    resolver.Output(path:, span:, ..) -> {
      use #(_reference, port) <- result.try(get_output(context, path, span))

      Ok(port)
    }

    resolver.Literal(port:, ..) -> Ok(port)
  }
}

fn get_port_target(context: context.Context, target: resolver.Target) {
  let resolver.Input(path:, span:, ..) = target

  use #(_reference, port) <- result.try(get_input(context, path, span))
  Ok(port)
}

fn get_input(context: context.Context, path: List(String), span) {
  case context.get_input(context, path) {
    Ok(input) -> Ok(input)
    Error(_error) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownInput(path), span:))
  }
}

fn get_output(context: context.Context, path: List(String), span) {
  case context.get_output(context, path) {
    Ok(output) -> Ok(output)
    Error(_error) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOutput(path), span:))
  }
}
