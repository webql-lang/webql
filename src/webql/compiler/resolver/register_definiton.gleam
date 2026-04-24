import webql/compiler/resolver/ast
import webql/compiler/runtime

/// Registers a definition.
pub fn register(
  runtime: runtime.Runtime,
  definition: ast.Definition,
  sub_runtime: runtime.Runtime,
) -> runtime.Runtime {
  runtime
  |> runtime.add_definition(definition.name)
  |> runtime.add_runtime(definition.reference, sub_runtime)
}
