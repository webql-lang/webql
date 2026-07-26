import webql/graph
import webql/linker/diagnostic
import webql/linker/link_program
import webql/program
import webql/schema

pub opaque type Linker {
  Linker(graph: graph.Graph, schema: schema.Schema)
}

/// Creates a new linker instance from a graph and schema.
pub fn new(graph: graph.Graph, schema: schema.Schema) -> Linker {
  Linker(graph:, schema:)
}

/// Links a graph into a program.
pub fn link(linker: Linker) -> Result(program.Program, diagnostic.Diagnostic) {
  link_program.link(linker.graph, linker.schema)
}
