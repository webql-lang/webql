import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/assembler
import webql/engine/diagnostic
import webql/engine/interpreter
import webql/engine/interpreter/memory
import webql/graph

pub type Engine(storage) {
  Engine(document: document.Document, memory: memory.Memory(storage))
}

/// Creates a new engine instance.
pub fn new(document: document.Document, memory: memory.Memory(storage)) {
  Engine(document:, memory:)
}

/// Runs a graph based from a document and a graph.
pub fn run(
  engine: Engine(storage),
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let assembler = assembler.new(engine.document)
  use plan <- result.try(run_assembler(assembler, graph))

  let interpreter = interpreter.new(plan)
  run_interpreter(interpreter, engine.memory, parameters)
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
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case interpreter.interpret(interpreter, memory, parameters) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.InterpreterDiagnostic(error.kind)),
      )
  }
}
