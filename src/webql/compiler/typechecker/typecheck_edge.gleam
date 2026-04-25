import webql/compiler/resolver/ast
import webql/compiler/runtime
import webql/compiler/typechecker/diagnostic

/// Typechecks an edge from resolver AST.
pub fn typecheck(
  edge: ast.Edge,
  runtime: runtime.Runtime,
) -> Result(Nil, diagnostic.Diagnostic) {
  let ast.Edge(from:, to:, span:, ..) = edge
  let expected = get_typename_input(runtime, to)
  let found = get_typename_output(runtime, from)

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
fn get_typename_output(runtime: runtime.Runtime, output: ast.Output) {
  case output {
    ast.PortOutput(path:, ..) -> {
      let assert Ok(#(_reference, typename)) = runtime.get_output(runtime, path)
      typename
    }

    ast.PrimitiveOutput(typename:, ..) -> typename
  }
}

fn get_typename_input(runtime: runtime.Runtime, input: ast.Input) {
  let ast.PortInput(path:, ..) = input
  let assert Ok(#(_reference, typename)) = runtime.get_input(runtime, path)
  typename
}
