import webql/assembler/linker/link_program
import webql/graph
import webql/schema

pub opaque type Linker {
  Linker(graph: graph.Graph)
}

/// Creates a new linker instance from a graph.
pub fn new(graph: graph.Graph) -> Linker {
  Linker(graph:)
}

/// Links a graph into a scheduler program.
pub fn link(linker: Linker, schema: schema.Schema) {
  link_program.link(linker.graph, schema)
}
