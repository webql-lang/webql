import gleam/dynamic
import gleam/result
import webql/assembler
import webql/compiler
import webql/diagnostic
import webql/engine
import webql/graph
import webql/interpreter
import webql/introspection
import webql/memory
import webql/schema

pub type Webql(task, storage) {
  Webql(
    memory: memory.Memory(storage),
    engine: engine.Engine(task, memory.Memory(storage), diagnostic.Diagnostic),
  )
}

/// Creates a new WebQL instance.
pub fn new(
  memory: memory.Memory(storage),
  engine: engine.Engine(task, memory.Memory(storage), diagnostic.Diagnostic),
) -> Webql(task, storage) {
  Webql(memory:, engine:)
}

/// Runs a WebQL source against a schema.
pub fn run(
  webql: Webql(task, storage),
  source: String,
  schema: schema.Schema(task),
  params: dynamic.Dynamic,
) -> task {
  let Webql(memory:, engine:) = webql

  engine.handle_run(fn() {
    use graph <- result.try(compile(source, schema))

    let assembler = assembler.new(schema)
    use plan <- result.try(run_assembler(assembler, graph))

    let interpreter = interpreter.new(plan)
    Ok(run_interpreter(interpreter, memory, engine, params))
  })
}

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  schema: schema.Schema(task),
) -> Result(graph.Graph, diagnostic.Diagnostic) {
  let introspection_schema = introspection.introspect(schema)
  let compiler = compiler.new(introspection_schema)

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
fn run_assembler(assembler: assembler.Assembler(task), graph: graph.Graph) {
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
  inputs: dynamic.Dynamic,
) {
  interpreter.interpret(interpreter, memory, engine, inputs)
}
