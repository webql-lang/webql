import gleam/dict
import gleam/dynamic
import gleam/result
import webql/diagnostic
import webql/document
import webql/graph
import webql/lang
import webql/vm
import webql/vm/interpreter/memory

pub type Webql(a, b) {
  Webql(vm: vm.Vm(a, b))
}

/// Creates a new WebQL instance.
pub fn new(
  document: document.Document,
  memory: memory.Memory(a, b),
) -> Webql(a, b) {
  let vm = vm.new(document, memory)
  Webql(vm:)
}

/// Runs a WebQL source against a document.
pub fn run(
  webql: Webql(a, b),
  source: String,
  document: document.Document,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  use graph <- result.try(compile(source, document))

  case vm.run(webql.vm, graph, parameters) {
    Ok(result) -> Ok(result)
    Error(error) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.VmDiagnostic(error.kind)))
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
