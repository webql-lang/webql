import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/diagnostic
import webql/engine/memory
import webql/engine/system
import webql/graph

pub opaque type Engine(a, b) {
  Engine(memory: memory.Memory(a, b))
}

/// Creates a new engine instance.
pub fn new(memory: memory.Memory(a, b)) {
  Engine(memory:)
}

/// Runs a graph based from a document and a graph.
pub fn run(
  engine: Engine(a, b),
  document: document.Document,
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  let system = system.new(engine.memory)
  case system.run(system, document, graph, parameters) {
    Ok(result) -> Ok(result)
    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SystemDiagnostic(error.kind)),
      )
  }
}
