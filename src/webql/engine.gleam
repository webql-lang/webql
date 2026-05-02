import gleam/dict
import gleam/dynamic
import gleam/result
import webql/document
import webql/engine/diagnostic
import webql/engine/linker
import webql/engine/runner
import webql/engine/scheduler
import webql/graph

pub type Engine {
  Engine
}

/// Runs a graph based from a document and a graph.
pub fn run(
  _engine: Engine,
  document: document.Document,
  graph: graph.Module,
  parameters: dict.Dict(String, dynamic.Dynamic),
) -> Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic) {
  let linker = linker.new(graph)
  use plan <- result.try(run_linker(linker, document))

  let scheduler = scheduler.new(plan)
  use plan <- result.try(run_scheduler(scheduler))

  let runner = runner.new(plan)
  run_runner(runner, parameters)
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

fn run_runner(
  runner: runner.Runner,
  parameters: dict.Dict(String, dynamic.Dynamic),
) {
  case runner.run(runner, parameters) {
    Ok(result) -> Ok(result)

    Error(error) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RunnerDiagnostic(error.kind)),
      )
  }
}
