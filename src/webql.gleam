import gleam/dict
import gleam/dynamic
import webql/diagnostic
import webql/document
import webql/engine
import webql/engine/assembler/plan
import webql/engine/diagnostic as engine_diagnostic
import webql/engine/interpreter/diagnostic as interpreter_diagnostic
import webql/engine/interpreter/memory
import webql/engine/interpreter/runtime
import webql/graph
import webql/lang
import webql/resolution

pub type Webql(storage) {
  Webql(engine: engine.Engine(storage))
}

/// Creates a new WebQL instance.
pub fn new(
  document: document.Document,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    plan.Batch,
    interpreter_diagnostic.Diagnostic,
  ),
) -> Webql(storage) {
  let engine = engine.new(document, memory, runtime)
  Webql(engine:)
}

/// Runs a WebQL source against a document.
pub fn run(
  webql: Webql(storage),
  source: String,
  document: document.Document,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> resolution.Resolution(dynamic.Dynamic, diagnostic.Diagnostic) {
  case compile(source, document) {
    Ok(graph) -> run_engine(webql.engine, graph, parameters)

    Error(error) -> resolution.Done(Error(error))
  }
}

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  document: document.Document,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  let schema = lang.introspect(document)
  case lang.compile(source, schema) {
    Ok(output) -> Ok(output)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LangDiagnostic(diagnostic.kind)),
      )
  }
}

// PRIVATE FUNCTIONS
// =================
fn run_engine(
  engine: engine.Engine(storage),
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case engine.run(engine, graph, parameters) {
    resolution.Done(result) -> resolution.Done(normalize(result))

    resolution.Pending(perform) ->
      resolution.Pending(fn(done) {
        perform(fn(result) { done(normalize(result)) })
      })
  }
}

fn normalize(result: Result(dynamic.Dynamic, engine_diagnostic.Diagnostic)) {
  case result {
    Ok(result) -> Ok(result)

    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.EngineDiagnostic(diagnostic.kind)),
      )
  }
}
