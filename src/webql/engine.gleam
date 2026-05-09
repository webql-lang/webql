import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/assembler
import webql/engine/assembler/plan
import webql/engine/diagnostic
import webql/engine/interpreter
import webql/engine/interpreter/diagnostic as interpreter_diagnostic
import webql/engine/interpreter/memory
import webql/engine/interpreter/runtime
import webql/graph
import webql/resolution

pub type Engine(storage) {
  Engine(
    document: document.Document,
    memory: memory.Memory(storage),
    runtime: runtime.Runtime(
      memory.Memory(storage),
      plan.Batch,
      interpreter_diagnostic.Diagnostic,
    ),
  )
}

/// Creates a new engine instance.
pub fn new(
  document: document.Document,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    plan.Batch,
    interpreter_diagnostic.Diagnostic,
  ),
) {
  Engine(document:, memory:, runtime:)
}

/// Runs a graph based from a document and a graph.
pub fn run(
  engine: Engine(storage),
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> resolution.Resolution(dynamic.Dynamic, diagnostic.Diagnostic) {
  let assembler = assembler.new(engine.document)
  let plan = run_assembler(assembler, graph)

  case plan {
    Ok(plan) -> {
      let interpreter = interpreter.new(plan)
      run_interpreter(interpreter, engine.memory, engine.runtime, parameters)
    }

    Error(diagnostic) -> resolution.Done(Error(diagnostic))
  }
}

// PRIVATE FUNCTIONS
// =================
fn run_assembler(assembler: assembler.Assembler, graph: graph.Module) {
  case assembler.assemble(assembler, graph) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.AssemblerDiagnostic(error.kind)),
      )
  }
}

fn run_interpreter(
  interpreter: interpreter.Interpreter,
  memory: memory.Memory(storage),
  runtime: runtime.Runtime(
    memory.Memory(storage),
    plan.Batch,
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
