import webql/lang/compiler/context
import webql/lang/compiler/resolver/ast

/// Registers a return.
pub fn register(context: context.Context, return: ast.Return) -> context.Context {
  context
  |> context.add_return(return.name)
  |> context.add_input([return.name], return.typename.reference)
}
