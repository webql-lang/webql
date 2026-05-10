import gleam/dict
import gleam/dynamic
import webql/assembler
import webql/compiler
import webql/diagnostic
import webql/document
import webql/graph
import webql/interpreter
import webql/interpreter/diagnostic as interpreter_diagnostic
import webql/interpreter/memory
import webql/interpreter/runtime
import webql/introspection
import webql/resolution

pub type Webql(storage) {
  Webql(
    document: document.Document,
    memory: memory.Memory(storage),
    runtime: runtime.Runtime(
      memory.Memory(storage),
      interpreter_diagnostic.Diagnostic,
    ),
  )
}

/// Creates a new WebQL instance.
pub fn new(
  document: document.Document,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    interpreter_diagnostic.Diagnostic,
  ),
) -> Webql(storage) {
  Webql(document:, memory:, runtime:)
}

/// Runs a WebQL source against a document.
pub fn run(
  webql: Webql(storage),
  source: String,
  document: document.Document,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> resolution.Resolution(dynamic.Dynamic, diagnostic.Diagnostic) {
  case compile(source, document) {
    Ok(graph) -> run_plan(webql, graph, parameters)

    Error(error) -> resolution.Done(Error(error))
  }
}

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  document: document.Document,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  let schema = introspection.introspect(document)
  let compiler = compiler.new(schema)

  case compiler.compile(compiler, source) {
    Ok(output) -> Ok(output)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.CompilerDiagnostic(
          diagnostic.kind,
        )),
      )
  }
}

// PRIVATE FUNCTIONS
// =================
fn run_plan(
  webql: Webql(storage),
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  let assembler = assembler.new(webql.document)

  case assembler.assemble(assembler, graph) {
    Ok(plan) -> {
      let interpreter = interpreter.new(plan)
      interpret(interpreter, webql.memory, webql.runtime, parameters)
    }

    Error(diagnostic) ->
      resolution.Done(
        Error(
          diagnostic.Diagnostic(kind: diagnostic.AssemblerDiagnostic(
            diagnostic.kind,
          )),
        ),
      )
  }
}

fn interpret(
  interpreter: interpreter.Interpreter,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    interpreter_diagnostic.Diagnostic,
  ),
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case interpreter.interpret(interpreter, memory, runtime, parameters) {
    resolution.Done(result) -> resolution.Done(normalize(result))

    resolution.Pending(perform) ->
      resolution.Pending(fn(done) {
        perform(fn(result) { done(normalize(result)) })
      })
  }
}

fn normalize(result: Result(dynamic.Dynamic, interpreter_diagnostic.Diagnostic)) {
  case result {
    Ok(result) -> Ok(result)

    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.InterpreterDiagnostic(
          diagnostic.kind,
        )),
      )
  }
}
