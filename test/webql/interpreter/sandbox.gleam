import gleam/dict
import gleam/dynamic
import webql/interpreter/memory as interpreter_memory
import webql/interpreter/runtime as interpreter_runtime
import webql/resolution

pub type Storage {
  Storage(values: dict.Dict(List(String), dynamic.Dynamic))
}

pub fn memory() -> interpreter_memory.Memory(Storage) {
  interpreter_memory.Memory(
    new: memory,
    storage: Storage(dict.new()),
    get: get,
    set: set,
    merge: merge,
  )
}

pub fn runtime() -> interpreter_runtime.Runtime(a, c) {
  interpreter_runtime.Runtime(
    batches: run_batches,
    steps: run_steps,
    resolve: resolve,
    nested: continue,
    complete: continue,
  )
}

pub fn get(
  memory: interpreter_memory.Memory(Storage),
  path: List(String),
) -> Result(dynamic.Dynamic, dynamic.Dynamic) {
  case dict.get(memory.storage.values, path) {
    Ok(value) -> Ok(value)
    Error(_nil) -> Error(dynamic.nil())
  }
}

pub fn set(
  memory: interpreter_memory.Memory(Storage),
  path: List(String),
  value: dynamic.Dynamic,
) -> interpreter_memory.Memory(Storage) {
  interpreter_memory.Memory(
    ..memory,
    storage: Storage(values: dict.insert(memory.storage.values, path, value)),
  )
}

pub fn merge(
  left: interpreter_memory.Memory(Storage),
  right: interpreter_memory.Memory(Storage),
) -> interpreter_memory.Memory(Storage) {
  let values =
    dict.fold(
      right.storage.values,
      left.storage.values,
      fn(values, path, value) { dict.insert(values, path, value) },
    )

  interpreter_memory.Memory(..left, storage: Storage(values:))
}

pub fn result(resolution: resolution.Resolution(a, b)) -> Result(a, b) {
  done(resolution)
}

fn run_batches(initial, batches) {
  case batches {
    [] -> resolution.Done(Ok(initial))
    [batch, ..rest] -> {
      case done(batch(initial)) {
        Ok(next) -> run_batches(next, rest)
        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn run_steps(initial, steps, merge) {
  case steps {
    [] -> resolution.Done(Ok(initial))
    [step, ..rest] -> {
      case done(step) {
        Ok(next) -> run_steps(merge(initial, next), rest, merge)
        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn resolve(resolution, next) {
  resolution
  |> done()
  |> next()
  |> resolution.Done()
}

fn continue(resolution, next) {
  case done(resolution) {
    Ok(value) -> resolution.Done(next(value))
    Error(error) -> resolution.Done(Error(error))
  }
}

fn done(resolution: resolution.Resolution(a, b)) -> Result(a, b) {
  case resolution {
    resolution.Done(result) -> result
    resolution.Pending(_perform) -> panic
  }
}
