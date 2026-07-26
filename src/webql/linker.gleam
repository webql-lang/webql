import webql/graph
import webql/linker/diagnostic
import webql/linker/link_plan
import webql/plan
import webql/schema

pub opaque type Linker {
  Linker(graph: graph.Graph, schema: schema.Schema)
}

/// Creates a new linker instance from a graph and schema.
pub fn new(graph: graph.Graph, schema: schema.Schema) -> Linker {
  Linker(graph:, schema:)
}

/// Links a graph into an executable plan.
pub fn link(linker: Linker) -> Result(plan.Plan, diagnostic.Diagnostic) {
  link_plan.link(linker.graph, linker.schema)
}
