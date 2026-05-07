import gleam/dict
import gleam/dynamic
import gleam/result
import webql/diagnostic
import webql/document
import webql/engine
import webql/graph
import webql/lang
import webql/lang/introspection

/// Runs a WebQL source against a document.
pub fn run(
  source: String,
  document: document.Document,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  let schema = introspect(document)
  use graph <- result.try(compile(source, schema))

  case engine.run(document, graph, parameters) {
    Ok(result) -> Ok(result)
    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.EngineDiagnostic(error.kind)),
      )
  }
}

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  schema: introspection.Schema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  case lang.compile(source, schema) {
    Ok(output) -> Ok(output)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LangDiagnostic(diagnostic.kind)),
      )
  }
}

/// Converts a WebQL document into a schema.
pub fn introspect(document: document.Document) -> introspection.Schema {
  introspection.introspect(document)
}
