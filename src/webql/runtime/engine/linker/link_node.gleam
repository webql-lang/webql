import gleam/dict
import gleam/result
import webql/document
import webql/runtime/engine/linker/diagnostic
import webql/runtime/engine/linker/plan

/// Links an external node into a scheduler resolver.
pub fn link(
  name: String,
  node: String,
  document: document.Document,
) -> Result(#(String, plan.Resolver), diagnostic.Diagnostic) {
  use function <- result.try(link_resolver(node, document))
  Ok(#(name, plan.FunctionResolver(function:)))
}

// PRIVATE FUNCTIONS
// =================
fn link_resolver(
  node: String,
  document: document.Document,
) -> Result(document.Resolver, diagnostic.Diagnostic) {
  let document.Document(operators:, ..) = document

  case dict.get(operators, node) {
    Ok(document.Operator(resolver:, ..)) -> Ok(resolver)

    Error(_nil) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator(node)))
  }
}
