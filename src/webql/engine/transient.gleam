import gleam/dynamic
import webql/engine
import webql/interpreter/diagnostic
import webql/memory

pub type Transient(storage)

/// Creates a new transient engine.
pub fn new() -> engine.Engine(
  Transient(storage),
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

@external(erlang, "transient_ffi", "run")
@external(javascript, "./transient_ffi.mjs", "run")
pub fn run(
  next: fn() -> Result(Transient(storage), diagnostic.Diagnostic),
) -> Transient(storage)

@external(erlang, "transient_ffi", "start_plan")
@external(javascript, "./transient_ffi.mjs", "startPlan")
pub fn start_plan(
  next: fn() ->
    Result(
      #(
        memory.Memory(storage),
        List(fn(memory.Memory(storage)) -> Transient(storage)),
      ),
      diagnostic.Diagnostic,
    ),
) -> Transient(storage)

@external(erlang, "transient_ffi", "finish_plan")
@external(javascript, "./transient_ffi.mjs", "finishPlan")
pub fn finish_plan(
  task: Transient(storage),
  next: fn(memory.Memory(storage)) ->
    Result(dynamic.Dynamic, diagnostic.Diagnostic),
) -> Transient(storage)

@external(erlang, "transient_ffi", "start_batch")
@external(javascript, "./transient_ffi.mjs", "startBatch")
pub fn start_batch(
  next: fn() -> Result(List(Transient(storage)), diagnostic.Diagnostic),
) -> Transient(storage)

@external(erlang, "transient_ffi", "finish_batch")
@external(javascript, "./transient_ffi.mjs", "finishBatch")
pub fn finish_batch(
  initial: memory.Memory(storage),
  task: Transient(storage),
  merge: fn(memory.Memory(storage), memory.Memory(storage)) ->
    memory.Memory(storage),
) -> Transient(storage)

@external(erlang, "transient_ffi", "start_step")
@external(javascript, "./transient_ffi.mjs", "startStep")
pub fn start_step(
  next: fn() -> Result(Transient(storage), diagnostic.Diagnostic),
) -> Transient(storage)

@external(erlang, "transient_ffi", "finish_step")
@external(javascript, "./transient_ffi.mjs", "finishStep")
pub fn finish_step(
  task: Transient(storage),
  next: fn(Result(dynamic.Dynamic, dynamic.Dynamic)) ->
    Result(memory.Memory(storage), diagnostic.Diagnostic),
) -> Transient(storage)
