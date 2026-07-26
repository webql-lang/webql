import gleam/dict
import webql/linker/diagnostic
import webql/program
import webql/schema

/// Links a schema node into a program node.
pub fn link(
  kind: String,
  schema: schema.Schema,
) -> Result(program.Node, diagnostic.Diagnostic) {
  let schema.Schema(nodes:, ..) = schema

  case dict.get(nodes, kind) {
    Ok(_node) -> Ok(program.Node(kind:))
    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode(kind)))
  }
}
