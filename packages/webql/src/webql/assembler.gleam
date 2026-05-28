import gleam/result
import webql/assembler/diagnostic
import webql/assembler/linker
import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler
import webql/graph
import webql/schema

pub opaque type Assembler(task) {
  Assembler(schema: schema.Schema(task))
}

/// Creates a new assembler instance from an executable plan.
pub fn new(schema: schema.Schema(task)) -> Assembler(task) {
  Assembler(schema: schema)
}

/// Runs an executable plan.
pub fn assemble(
  assembler: Assembler(task),
  graph: graph.Graph,
) -> Result(plan.Plan(task), diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(assemble_linker(linker, assembler.schema))

  let scheduler = scheduler.new(plan)
  assemble_scheduler(scheduler)
}

// PRIVATE FUNCTIONS
// =================
fn assemble_linker(
  linker: linker.Linker,
  schema: schema.Schema(task),
) -> Result(linker_program.Program(task), diagnostic.Diagnostic) {
  case linker.link(linker, schema) {
    Ok(plan) -> Ok(plan)
    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LinkerDiagnostic(error.kind)),
      )
  }
}

fn assemble_scheduler(
  scheduler: scheduler.Scheduler(task),
) -> Result(plan.Plan(task), diagnostic.Diagnostic) {
  case scheduler.schedule(scheduler) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SchedulerDiagnostic(error.kind)),
      )
  }
}
