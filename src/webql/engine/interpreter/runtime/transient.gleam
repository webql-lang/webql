import gleam/dynamic
import webql/engine/interpreter/runtime
import webql/resolution

/// Creates a runtime that schedules transient pending work on the current target.
pub fn new() -> runtime.Runtime(a, c) {
  runtime.Runtime(batches:, steps:, resolve:, nested: inline, complete:)
}

@external(erlang, "transient_ffi", "batches")
@external(javascript, "./transient_ffi.mjs", "batches")
fn batches(
  _initial: a,
  _batches: List(fn(a) -> resolution.Resolution(a, c)),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.batches is target-specific"
}

@external(erlang, "transient_ffi", "steps")
@external(javascript, "./transient_ffi.mjs", "steps")
fn steps(
  _initial: a,
  _steps: List(resolution.Resolution(a, c)),
  _merge: fn(a, a) -> a,
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.steps is target-specific"
}

@external(erlang, "transient_ffi", "resolve")
@external(javascript, "./transient_ffi.mjs", "resolve")
fn resolve(
  _resolution: resolution.Resolution(dynamic.Dynamic, dynamic.Dynamic),
  _next: fn(Result(dynamic.Dynamic, dynamic.Dynamic)) -> Result(a, c),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.resolve is target-specific"
}

@external(erlang, "transient_ffi", "inline")
@external(javascript, "./transient_ffi.mjs", "inline")
fn inline(
  _resolution: resolution.Resolution(a, c),
  _next: fn(a) -> Result(a, c),
) -> resolution.Resolution(a, c) {
  panic as "webql/engine/interpreter/runtime/transient.inline is target-specific"
}

@external(erlang, "transient_ffi", "complete")
@external(javascript, "./transient_ffi.mjs", "complete")
fn complete(
  _resolution: resolution.Resolution(a, c),
  _next: fn(a) -> Result(dynamic.Dynamic, c),
) -> resolution.Resolution(dynamic.Dynamic, c) {
  panic as "webql/engine/interpreter/runtime/transient.complete is target-specific"
}
