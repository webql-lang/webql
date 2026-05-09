import gleam/result
import webql/document
import webql/engine/assembler/diagnostic
import webql/engine/assembler/linker
import webql/engine/assembler/plan
import webql/engine/assembler/scheduler
import webql/graph

pub opaque type Assembler {
  Assembler(document: document.Document)
}

/// Creates a new assembler instance from an executable plan.
pub fn new(document: document.Document) -> Assembler {
  Assembler(document:)
}

/// Runs an executable plan.
pub fn assemble(
  assembler: Assembler,
  graph: graph.Module,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(assemble_linker(linker, assembler.document))

  let scheduler = scheduler.new(plan)
  assemble_scheduler(scheduler)
}

// PRIVATE FUNCTIONS
// =================
fn assemble_linker(linker: linker.Linker, document: document.Document) {
  case linker.link(linker, document) {
    Ok(plan) -> Ok(plan)
    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LinkerDiagnostic(error.kind)),
      )
  }
}

fn assemble_scheduler(scheduler: scheduler.Scheduler) {
  case scheduler.schedule(scheduler) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SchedulerDiagnostic(error.kind)),
      )
  }
}
