import gleam/dict
import gleam/result
import webql/assembler/linker/diagnostic
import webql/assembler/linker/program
import webql/schema

/// Links an external node into a scheduler resolver.
pub fn link(
  name: String,
  node: String,
  schema: schema.Schema(task),
) -> Result(#(String, program.Node(task)), diagnostic.Diagnostic) {
  use function <- result.try(link_resolver(node, schema))
  Ok(#(name, program.Node(resolver: function)))
}

// PRIVATE FUNCTIONS
// =================
fn link_resolver(
  node: String,
  schema: schema.Schema(task),
) -> Result(schema.Resolver(task), diagnostic.Diagnostic) {
  let schema.Schema(operations:, ..) = schema

  case dict.get(operations, node) {
    Ok(schema.Operation(resolver:, ..)) -> Ok(resolver)

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator(node)))
  }
}
