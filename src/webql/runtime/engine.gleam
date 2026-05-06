import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/graph
import webql/runtime/engine/diagnostic
import webql/runtime/engine/linker
import webql/runtime/engine/scheduler
import webql/runtime/engine/traverser

pub type Engine {
  Engine
}

/// Runs a graph based from a document and a graph.
pub fn traverse(
  _engine: Engine,
  document: document.Document,
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(traverse_linker(linker, document))

  let scheduler = scheduler.new(plan)
  use plan <- result.try(traverse_scheduler(scheduler))

  let traverser = traverser.new(plan)
  traverse_traverser(traverser, parameters)
}

// PRIVATE FUNCTIONS
// =================
fn traverse_linker(linker: linker.Linker, document: document.Document) {
  case linker.link(linker, document) {
    Ok(plan) -> Ok(plan)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LinkerDiagnostic(error.kind)),
      )
  }
}

fn traverse_scheduler(scheduler: scheduler.Scheduler) {
  case scheduler.schedule(scheduler) {
    Ok(plan) -> Ok(plan)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.SchedulerDiagnostic(error.kind)),
      )
  }
}

fn traverse_traverser(
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
