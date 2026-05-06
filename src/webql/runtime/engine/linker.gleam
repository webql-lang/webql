import webql/document
import webql/graph
import webql/runtime/engine/linker/diagnostic
import webql/runtime/engine/linker/link_plan
import webql/runtime/engine/linker/plan

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
