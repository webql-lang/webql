import webql/document
import webql/engine/linker/diagnostic
import webql/engine/linker/link_plan
import webql/engine/linker/plan
import webql/graph

pub opaque type Linker {
  Linker(module: graph.Module)
}

/// Creates a new linker instance from a graph module.
pub fn new(module: graph.Module) -> Linker {
  Linker(module:)
}

/// Links a graph module into a scheduler plan.
pub fn link(
  linker: Linker,
  document: document.Document,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  link_plan.link(linker.module, document)
}
