import webql/lang/compiler/context
import webql/lang/compiler/resolver/ast

/// Registers a parameter.
pub fn register(
  context: context.Context,
  parameter: ast.Parameter,
) -> context.Context {
  context
  |> context.add_parameter(parameter.name)
  |> context.add_output([parameter.name], parameter.typename.reference)
}
