import gleam/dynamic
import webql/engine/interpreter/runtime
import webql/resolution

/// Creates a runtime that schedules transient pending work on the current target.
pub fn new() -> runtime.Runtime(a, b, c) {
  runtime.Runtime(batches:, steps:, resolve:, inline:, complete:)
}

@external(erlang, "webql_engine_interpreter_runtime_transient_ffi", "batches")
@external(javascript, "./transient_ffi.mjs", "batches")
fn batches(
  initial: a,
  batches: List(b),
  interpret: fn(a, b) -> resolution.Resolution(a, c),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.batches is target-specific"
}

@external(erlang, "webql_engine_interpreter_runtime_transient_ffi", "steps")
@external(javascript, "./transient_ffi.mjs", "steps")
fn steps(
  initial: a,
  steps: List(resolution.Resolution(a, c)),
  merge: fn(a, a) -> a,
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.steps is target-specific"
}

@external(erlang, "webql_engine_interpreter_runtime_transient_ffi", "resolve")
@external(javascript, "./transient_ffi.mjs", "resolve")
fn resolve(
  resolution: resolution.Resolution(dynamic.Dynamic, dynamic.Dynamic),
  next: fn(Result(dynamic.Dynamic, dynamic.Dynamic)) -> Result(a, c),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.resolve is target-specific"
}

@external(erlang, "webql_engine_interpreter_runtime_transient_ffi", "inline")
@external(javascript, "./transient_ffi.mjs", "inline")
fn inline(
  resolution: resolution.Resolution(a, c),
  next: fn(a) -> Result(a, c),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.inline is target-specific"
}

@external(erlang, "webql_engine_interpreter_runtime_transient_ffi", "complete")
@external(javascript, "./transient_ffi.mjs", "complete")
fn complete(
  resolution: resolution.Resolution(a, c),
  next: fn(a) -> Result(dynamic.Dynamic, c),
) -> resolution.Resolution(dynamic.Dynamic, c) {
  panic as "webql/engine/interpreter/runtime/transient.complete is target-specific"
}
