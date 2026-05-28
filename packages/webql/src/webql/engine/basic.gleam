import gleam/dynamic
import webql/engine
import webql/interpreter/diagnostic
import webql/memory

pub type Basic(storage)

/// Creates a new basic engine.
pub fn new() -> engine.Engine(
  Basic(storage),
  memory.Memory(storage),
  diagnostic.Diagnostic,
) {
  engine.Engine(
    handle_run:,
    handle_start_plan:,
    handle_finish_plan:,
    handle_start_batch:,
    handle_finish_batch:,
    handle_start_step:,
    handle_finish_step:,
  )
}

@external(erlang, "basic_ffi", "handle_run")
@external(javascript, "./basic_ffi.mjs", "handleRun")
pub fn handle_run(
  next: fn() -> Result(Basic(storage), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_start_plan")
@external(javascript, "./basic_ffi.mjs", "handleStartPlan")
pub fn handle_start_plan(
  next: fn() ->
    Result(
      #(
        memory.Memory(storage),
        List(fn(memory.Memory(storage)) -> Basic(storage)),
      ),
      diagnostic.Diagnostic,
    ),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_finish_plan")
@external(javascript, "./basic_ffi.mjs", "handleFinishPlan")
pub fn handle_finish_plan(
  task: Basic(storage),
  next: fn(memory.Memory(storage)) ->
    Result(dynamic.Dynamic, diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_start_batch")
@external(javascript, "./basic_ffi.mjs", "handleStartBatch")
pub fn handle_start_batch(
  next: fn() -> Result(List(Basic(storage)), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_finish_batch")
@external(javascript, "./basic_ffi.mjs", "handleFinishBatch")
pub fn handle_finish_batch(
  initial: memory.Memory(storage),
  task: Basic(storage),
  merge: fn(memory.Memory(storage), memory.Memory(storage)) ->
    memory.Memory(storage),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_start_step")
@external(javascript, "./basic_ffi.mjs", "handleStartStep")
pub fn handle_start_step(
  next: fn() -> Result(Basic(storage), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "handle_finish_step")
@external(javascript, "./basic_ffi.mjs", "handleFinishStep")
pub fn handle_finish_step(
  task: Basic(storage),
  next: fn(Result(dynamic.Dynamic, dynamic.Dynamic)) ->
    Result(memory.Memory(storage), diagnostic.Diagnostic),
) -> Basic(storage)
