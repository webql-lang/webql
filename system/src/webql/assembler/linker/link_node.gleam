import gleam/dict
import gleam/result
import webql/assembler/linker/diagnostic
import webql/assembler/linker/program
import webql/document

/// Links an external node into a scheduler resolver.
pub fn link(
  name: String,
  node: String,
  document: document.Document(task),
) -> Result(#(String, program.Resolver(task)), diagnostic.Diagnostic) {
  use function <- result.try(link_resolver(node, document))
  Ok(#(name, program.FunctionResolver(function:)))
}

// PRIVATE FUNCTIONS
// =================
fn link_resolver(
  node: String,
  document: document.Document(task),
) -> Result(document.Resolver(task), diagnostic.Diagnostic) {
  let document.Document(operators:, ..) = document

  case dict.get(operators, node) {
    Ok(document.Operator(resolver:, ..)) -> Ok(resolver)

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator(node)))
  }
}
