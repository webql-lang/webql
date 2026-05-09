import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/graph
import webql/vm/assembler
import webql/vm/diagnostic
import webql/vm/interpreter
import webql/vm/interpreter/memory

pub type Vm(a, b) {
  Vm(document: document.Document, memory: memory.Memory(a, b))
}

/// Creates a new vm instance.
pub fn new(document: document.Document, memory: memory.Memory(a, b)) {
  Vm(document:, memory:)
}

/// Runs a graph based from a document and a graph.
pub fn run(
  vm: Vm(a, b),
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let assembler = assembler.new(vm.document)
  use plan <- result.try(run_assembler(assembler, graph))

  let interpreter = interpreter.new(plan)
  run_interpreter(interpreter, vm.memory, parameters)
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
  memory: memory.Memory(a, b),
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
