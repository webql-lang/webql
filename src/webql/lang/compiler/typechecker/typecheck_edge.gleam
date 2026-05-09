import webql/lang/compiler/context
import webql/lang/compiler/hir
import webql/lang/compiler/typechecker/diagnostic

/// Typechecks an edge from resolver AST.
pub fn typecheck(
  edge: hir.Edge,
  context: context.Context,
) -> Result(Nil, diagnostic.Diagnostic) {
  let hir.Edge(from:, to:, span:, ..) = edge
  let expected = get_typename_input(context, to)
  let found = get_typename_output(context, from)

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
fn get_typename_output(context: context.Context, output: hir.Output) {
  case output {
    hir.PortOutput(path:, ..) -> {
      let assert Ok(#(_reference, typename)) = context.get_output(context, path)
      typename
    }

    hir.PrimitiveOutput(typename:, ..) -> typename
  }
}

fn get_typename_input(context: context.Context, input: hir.Input) {
  let hir.PortInput(path:, ..) = input
  let assert Ok(#(_reference, typename)) = context.get_input(context, path)
  typename
}
