import gleam/dict
import gleam/dynamic
import gleam/list
import webql/engine
import webql/interpreter/diagnostic
import webql/memory as webql_memory

pub type Storage {
  Storage(values: dict.Dict(List(String), dynamic.Dynamic))
}

pub type Task {
  Dynamic(Result(dynamic.Dynamic, diagnostic.Diagnostic))
  Memory(Result(webql_memory.Memory(Storage), diagnostic.Diagnostic))
  Resolver(Result(dynamic.Dynamic, dynamic.Dynamic))
  Steps(Result(List(Task), diagnostic.Diagnostic))
}

pub fn memory() -> webql_memory.Memory(Storage) {
  webql_memory.Memory(
    new: memory,
    storage: Storage(dict.new()),
    get: get,
    set: set,
    merge: merge,
  )
}

pub fn engine() -> engine.Engine(
  Task,
  webql_memory.Memory(Storage),
  diagnostic.Diagnostic,
) {
  engine.Engine(
    run: run,
    start_plan: start_plan,
    finish_plan: finish_plan,
    start_batch: start_batch,
    finish_batch: finish_batch,
    start_step: start_step,
    finish_step: finish_step,
  )
}

pub fn runtime() {
  engine()
}

pub fn ok(values: dict.Dict(String, dynamic.Dynamic)) -> Task {
  Resolver(Ok(encode(values)))
}

pub fn output(value: dynamic.Dynamic) -> Task {
  Resolver(Ok(value))
}

pub fn fail(message: dynamic.Dynamic) -> Task {
  Resolver(Error(message))
}

pub fn memory_task(
  result: Result(webql_memory.Memory(Storage), diagnostic.Diagnostic),
) -> Task {
  Memory(result)
}

pub fn result(task: Task) -> Result(dynamic.Dynamic, diagnostic.Diagnostic) {
  case task {
    Dynamic(result) -> result
    Memory(Error(error)) -> Error(error)
    Resolver(Error(message)) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.RuntimeError(step: "", message:)),
      )
    _ -> panic
  }
}

pub fn memory_result(
  task: Task,
) -> Result(webql_memory.Memory(Storage), diagnostic.Diagnostic) {
  case task {
    Memory(result) -> result
    Dynamic(Error(error)) -> Error(error)
    _ -> panic
  }
}

pub fn get(
  memory: webql_memory.Memory(Storage),
  path: List(String),
) -> Result(dynamic.Dynamic, dynamic.Dynamic) {
  case dict.get(memory.storage.values, path) {
    Ok(value) -> Ok(value)
    Error(_nil) -> Error(dynamic.nil())
  }
}

pub fn set(
  memory: webql_memory.Memory(Storage),
  path: List(String),
  value: dynamic.Dynamic,
) -> webql_memory.Memory(Storage) {
  webql_memory.Memory(
    ..memory,
    storage: Storage(values: dict.insert(memory.storage.values, path, value)),
  )
}

pub fn merge(
  left: webql_memory.Memory(Storage),
  right: webql_memory.Memory(Storage),
) -> webql_memory.Memory(Storage) {
  let values =
    dict.fold(
      right.storage.values,
      left.storage.values,
      fn(values, path, value) { dict.insert(values, path, value) },
    )

  webql_memory.Memory(..left, storage: Storage(values:))
}

fn run(next) {
  case next() {
    Ok(task) -> task
    Error(error) -> Dynamic(Error(error))
  }
}

fn start_plan(next) {
  case next() {
    Ok(#(initial, batches)) -> run_batches(initial, batches)
    Error(error) -> Memory(Error(error))
  }
}

fn start_batch(next) {
  Steps(next())
}

fn finish_batch(initial, task, merge) {
  case task {
    Steps(Ok(steps)) -> run_steps(initial, steps, merge)
    Steps(Error(error)) -> Memory(Error(error))
    _ -> panic
  }
}

fn start_step(next) {
  case next() {
    Ok(task) -> task
    Error(error) -> Memory(Error(error))
  }
}

fn finish_step(task, next) {
  case resolver_result(task) {
    Ok(result) -> Memory(next(result))
    Error(error) -> Memory(Error(error))
  }
}

fn finish_plan(task, next) {
  case memory_result(task) {
    Ok(memory) -> Dynamic(next(memory))
    Error(error) -> Dynamic(Error(error))
  }
}

fn run_batches(initial, batches) {
  case batches {
    [] -> Memory(Ok(initial))
    [batch, ..rest] -> {
      case memory_result(batch(initial)) {
        Ok(memory) -> run_batches(memory, rest)
        Error(error) -> Memory(Error(error))
      }
    }
  }
}

fn run_steps(initial, steps, merge) {
  case steps {
    [] -> Memory(Ok(initial))
    [step, ..rest] -> {
      case memory_result(step) {
        Ok(memory) -> run_steps(merge(initial, memory), rest, merge)
        Error(error) -> Memory(Error(error))
      }
    }
  }
}

fn resolver_result(
  task: Task,
) -> Result(Result(dynamic.Dynamic, dynamic.Dynamic), diagnostic.Diagnostic) {
  case task {
    Resolver(result) -> Ok(result)
    Dynamic(Ok(value)) -> Ok(Ok(value))
    Dynamic(Error(error)) -> Error(error)
    Memory(Error(error)) -> Error(error)
    _ -> panic
  }
}

fn encode(values: dict.Dict(String, dynamic.Dynamic)) {
  values
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(key, value) = entry
    #(dynamic.string(key), value)
  })
  |> dynamic.properties()
}
