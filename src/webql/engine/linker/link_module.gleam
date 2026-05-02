import webql/document
import webql/engine/linker/diagnostic
import webql/engine/linker/link_operation
import webql/engine/linker/plan
import webql/graph

/// Links a graph module into a scheduler plan.
pub fn link(
  module: graph.Module,
  document: document.Document,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  link_operation.link(module.operation, document)
}
