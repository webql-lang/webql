import webql/compiler/resolver/ast
import webql/compiler/resolver/runtime

/// Registers a return.
pub fn register(runtime: runtime.Runtime, return: ast.Return) -> runtime.Runtime {
  runtime
  |> runtime.add_return(return.name)
  |> runtime.add_input([return.name], return.typename.reference)
}
