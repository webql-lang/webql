import gleam/dynamic
import gleam/result
import webql/assembler
import webql/compiler
import webql/diagnostic
import webql/document
import webql/engine
import webql/graph
import webql/interpreter
import webql/introspection
import webql/memory

pub type Webql(task, storage) {
  Webql(
    document: document.Document(task),
    memory: memory.Memory(storage),
    engine: engine.Engine(task, memory.Memory(storage), diagnostic.Diagnostic),
  )
}

/// Creates a new WebQL instance.
pub fn new(
  document: document.Document(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), diagnostic.Diagnostic),
) -> Webql(task, storage) {
  Webql(document:, memory:, engine:)
}

/// Runs a WebQL source against a document.
pub fn run(
  webql: Webql(task, storage),
  source: String,
  document: document.Document(task),
  parameters: dynamic.Dynamic,
) -> task {
  let Webql(engine:, memory:, ..) = webql

  engine.run(fn() {
    use graph <- result.try(compile(source, document))

    let assembler = assembler.new(webql.document)
    use plan <- result.try(run_assembler(assembler, graph))

    let interpreter = interpreter.new(plan)
    Ok(run_interpreter(interpreter, memory, engine, parameters))
  })
}

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  document: document.Document(task),
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
fn run_assembler(assembler: assembler.Assembler(task), graph: graph.Module) {
  case assembler.assemble(assembler, graph) {
    Ok(plan) -> Ok(plan)

    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.AssemblerDiagnostic(
          diagnostic.kind,
        )),
      )
  }
}

fn run_interpreter(
  interpreter: interpreter.Interpreter(task),
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), diagnostic.Diagnostic),
  parameters: dynamic.Dynamic,
) {
  interpreter.interpret(interpreter, memory, engine, parameters)
}
