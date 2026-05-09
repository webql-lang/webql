import webql/document
import webql/engine/assembler/linker/diagnostic
import webql/engine/assembler/linker/link_program
import webql/engine/assembler/linker/program
import webql/graph

pub opaque type Linker {
  Linker(module: graph.Module)
}

/// Creates a new linker instance from a graph module.
pub fn new(module: graph.Module) -> Linker {
  Linker(module:)
}

/// Links a graph module into a scheduler program.
pub fn link(
  linker: Linker,
  document: document.Document,
) -> Result(program.Program, diagnostic.Diagnostic) {
  link_program.link(linker.module, document)
}
