import gleam/dict
import webql/linker/diagnostic
import webql/plan
import webql/schema

/// Links a runtime operation into an executable plan node.
pub fn link(
  operation: String,
  schema: schema.Schema,
) -> Result(plan.Node, diagnostic.Diagnostic) {
  let schema.Schema(operations:, ..) = schema

  case dict.get(operations, operation) {
    Ok(schema.Operation(resolver:, ..)) -> Ok(plan.Node(resolver:))
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperation(operation)))
  }
}
