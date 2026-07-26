import gleam/dict
import webql/linker/diagnostic
import webql/program
import webql/schema

/// Links a schema operation into a program node.
pub fn link(
  operation: String,
  schema: schema.Schema,
) -> Result(program.Node, diagnostic.Diagnostic) {
  let schema.Schema(operations:, ..) = schema

  case dict.get(operations, operation) {
    Ok(_operation) -> Ok(program.Node(operation:))
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperation(operation)))
  }
}
