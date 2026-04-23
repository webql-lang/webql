import webql/compiler/resolver/ast
import webql/compiler/resolver/runtime

/// Registers a parameter.
pub fn register(
  runtime: runtime.Runtime,
  parameter: ast.Parameter,
) -> runtime.Runtime {
  runtime
  |> runtime.add_parameter(parameter.name)
  |> runtime.add_output([parameter.name], parameter.typename.reference)
}
