import gleam/dynamic
import webql/runner/diagnostic

pub type HandleRun(task, error) =
  fn(fn() -> Result(task, error)) -> task

pub type HandleStartPlan(task, memory) =
  fn(fn() -> Result(#(memory, List(fn(memory) -> task)), diagnostic.Diagnostic)) ->
    task

pub type HandleStartBatch(task) =
  fn(fn() -> Result(List(task), diagnostic.Diagnostic)) -> task

pub type HandleFinishBatch(task, memory) =
  fn(memory, task, fn(memory, memory) -> memory) -> task

pub type HandleStartStep(task) =
  fn(fn() -> Result(task, diagnostic.Diagnostic)) -> task

pub type HandleFinishStep(task, memory) =
  fn(
    task,
    fn(Result(dynamic.Dynamic, dynamic.Dynamic)) ->
      Result(memory, diagnostic.Diagnostic),
  ) -> task

pub type HandleFinishPlan(task, memory) =
  fn(task, fn(memory) -> Result(dynamic.Dynamic, diagnostic.Diagnostic)) -> task

pub type Engine(task, memory, error) {
  Engine(
    handle_run: HandleRun(task, error),
    handle_start_plan: HandleStartPlan(task, memory),
    handle_finish_plan: HandleFinishPlan(task, memory),
    handle_start_batch: HandleStartBatch(task),
    handle_finish_batch: HandleFinishBatch(task, memory),
    handle_start_step: HandleStartStep(task),
    handle_finish_step: HandleFinishStep(task, memory),
  )
}
