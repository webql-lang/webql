import webql/assembler/linker/diagnostic
import webql/assembler/linker/link_program
import webql/assembler/linker/program
import webql/graph
import webql/schema

pub opaque type Linker {
  Linker(document: graph.Graph)
}

/// Creates a new linker instance from a graph document.
pub fn new(document: graph.Graph) -> Linker {
  Linker(document:)
}

/// Links a graph document into a scheduler program.
pub fn link(
  linker: Linker,
  schema: schema.Schema(task),
) -> Result(program.Program(task), diagnostic.Diagnostic) {
  link_program.link(linker.document, schema)
}
