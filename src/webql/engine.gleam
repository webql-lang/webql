import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/diagnostic
import webql/engine/system
import webql/graph

/// Runs a graph based from a document and a graph.
pub fn run(
  document: document.Document,
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case system.run(system.System, document, graph, parameters) {
    Ok(result) -> Ok(result)
    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SystemDiagnostic(error.kind)),
      )
  }
}
