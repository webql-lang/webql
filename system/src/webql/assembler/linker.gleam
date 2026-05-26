import webql/assembler/linker/diagnostic
import webql/assembler/linker/link_program
import webql/assembler/linker/program
import webql/graph
import webql/schema

pub opaque type Linker {
  Linker(module: graph.Graph)
}

/// Creates a new linker instance from a graph module.
pub fn new(module: graph.Graph) -> Linker {
  Linker(module:)
}

/// Links a graph module into a scheduler program.
pub fn link(
  linker: Linker,
  schema: schema.Schema(task),
) -> Result(program.Program(task), diagnostic.Diagnostic) {
  link_program.link(linker.module, schema)
}
