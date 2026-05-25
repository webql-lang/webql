import gleam/result
import webql/assembler/diagnostic
import webql/assembler/linker
import webql/assembler/linker/program as linker_program
import webql/assembler/plan
import webql/assembler/scheduler
import webql/document
import webql/graph

pub opaque type Assembler(task) {
  Assembler(document: document.Document(task))
}

/// Creates a new assembler instance from an executable plan.
pub fn new(document: document.Document(task)) -> Assembler(task) {
  Assembler(document:)
}

/// Runs an executable plan.
pub fn assemble(
  assembler: Assembler(task),
  graph: graph.Module,
) -> Result(plan.Plan(task), diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(assemble_linker(linker, assembler.document))

  let scheduler = scheduler.new(plan)
  assemble_scheduler(scheduler)
}

// PRIVATE FUNCTIONS
// =================
fn assemble_linker(
  linker: linker.Linker,
  document: document.Document(task),
) -> Result(linker_program.Program(task), diagnostic.Diagnostic) {
  case linker.link(linker, document) {
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
