import webql/compiler/context
import webql/compiler/resolver/hir

/// Registers a parameter.
pub fn register(
  context: context.Context,
  parameter: hir.Parameter,
) -> context.Context {
  context
  |> context.add_parameter(parameter.name)
  |> context.add_output([parameter.name], parameter.port.reference)
}
