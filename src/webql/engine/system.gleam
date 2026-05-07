import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/system/diagnostic
import webql/engine/system/linker
import webql/engine/system/scheduler
import webql/engine/system/traverser
import webql/graph

pub type System {
  System
}

/// Runs a graph based from a document and a graph.
pub fn run(
  _system: System,
  document: document.Document,
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(run_linker(linker, document))

  let scheduler = scheduler.new(plan)
  use plan <- result.try(run_scheduler(scheduler))

  let traverser = traverser.new(plan)
  run_traverser(traverser, parameters)
}

// PRIVATE FUNCTIONS
// =================
fn run_linker(linker: linker.Linker, document: document.Document) {
  case linker.link(linker, document) {
    Ok(plan) -> Ok(plan)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LinkerDiagnostic(error.kind)),
      )
  }
}

fn run_scheduler(scheduler: scheduler.Scheduler) {
  case scheduler.schedule(scheduler) {
    Ok(plan) -> Ok(plan)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SchedulerDiagnostic(error.kind)),
      )
  }
}

fn run_traverser(
  traverser: traverser.Traverser,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case traverser.traverse(traverser, parameters) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.TraverserDiagnostic(error.kind)),
      )
  }
}
