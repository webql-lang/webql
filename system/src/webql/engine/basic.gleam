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
    run:,
    start_plan:,
    finish_plan:,
    start_batch:,
    finish_batch:,
    start_step:,
    finish_step:,
  )
}

@external(erlang, "basic_ffi", "run")
@external(javascript, "./basic_ffi.mjs", "run")
pub fn run(
  next: fn() -> Result(Basic(storage), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "start_plan")
@external(javascript, "./basic_ffi.mjs", "startPlan")
pub fn start_plan(
  next: fn() ->
    Result(
      #(
        memory.Memory(storage),
        List(fn(memory.Memory(storage)) -> Basic(storage)),
      ),
      diagnostic.Diagnostic,
    ),
) -> Basic(storage)

@external(erlang, "basic_ffi", "finish_plan")
@external(javascript, "./basic_ffi.mjs", "finishPlan")
pub fn finish_plan(
  task: Basic(storage),
  next: fn(memory.Memory(storage)) ->
    Result(dynamic.Dynamic, diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "start_batch")
@external(javascript, "./basic_ffi.mjs", "startBatch")
pub fn start_batch(
  next: fn() -> Result(List(Basic(storage)), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "finish_batch")
@external(javascript, "./basic_ffi.mjs", "finishBatch")
pub fn finish_batch(
  initial: memory.Memory(storage),
  task: Basic(storage),
  merge: fn(memory.Memory(storage), memory.Memory(storage)) ->
    memory.Memory(storage),
) -> Basic(storage)

@external(erlang, "basic_ffi", "start_step")
@external(javascript, "./basic_ffi.mjs", "startStep")
pub fn start_step(
  next: fn() -> Result(Basic(storage), diagnostic.Diagnostic),
) -> Basic(storage)

@external(erlang, "basic_ffi", "finish_step")
@external(javascript, "./basic_ffi.mjs", "finishStep")
pub fn finish_step(
  task: Basic(storage),
  next: fn(Result(dynamic.Dynamic, dynamic.Dynamic)) ->
    Result(memory.Memory(storage), diagnostic.Diagnostic),
) -> Basic(storage)
