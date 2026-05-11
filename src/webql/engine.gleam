import gleam/dynamic
import webql/interpreter/diagnostic

pub type Run(task, error) =
  fn(fn() -> Result(task, error)) -> task

pub type StartPlan(task, memory) =
  fn(fn() -> Result(#(memory, List(fn(memory) -> task)), diagnostic.Diagnostic)) ->
    task

pub type StartBatch(task) =
  fn(fn() -> Result(List(task), diagnostic.Diagnostic)) -> task

pub type FinishBatch(task, memory) =
  fn(memory, task, fn(memory, memory) -> memory) -> task

pub type StartStep(task) =
  fn(fn() -> Result(task, diagnostic.Diagnostic)) -> task

pub type FinishStep(task, memory) =
  fn(
    task,
    fn(Result(dynamic.Dynamic, dynamic.Dynamic)) ->
      Result(memory, diagnostic.Diagnostic),
  ) ->
    task

pub type FinishPlan(task, memory) =
  fn(task, fn(memory) -> Result(dynamic.Dynamic, diagnostic.Diagnostic)) -> task

pub type Engine(task, memory, error) {
  Engine(
    run: Run(task, error),
    start_plan: StartPlan(task, memory),
    finish_plan: FinishPlan(task, memory),
    start_batch: StartBatch(task),
    finish_batch: FinishBatch(task, memory),
    start_step: StartStep(task),
    finish_step: FinishStep(task, memory),
  )
}
