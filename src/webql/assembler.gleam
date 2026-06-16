import gleam/result
import webql/assembler/diagnostic
import webql/assembler/linker
import webql/assembler/plan
import webql/assembler/scheduler
import webql/graph
import webql/schema

pub opaque type Assembler {
  Assembler(schema: schema.Schema)
}

/// Creates a new assembler instance from an executable plan.
pub fn new(schema: schema.Schema) -> Assembler {
  Assembler(schema: schema)
}

/// Runs an executable plan.
pub fn assemble(
  assembler: Assembler,
  graph: graph.Graph,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(assemble_linker(linker, assembler.schema))

  let scheduler = scheduler.new(plan)
  assemble_scheduler(scheduler)
}

// PRIVATE FUNCTIONS
// =================
fn assemble_linker(linker: linker.Linker, schema: schema.Schema) {
  case linker.link(linker, schema) {
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
