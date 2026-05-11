import gleam/dict
import gleam/dynamic
import gleam/list
import webql/engine
import webql/interpreter/diagnostic
import webql/memory as webql_memory

pub type Storage {
  Storage(values: dict.Dict(List(String), dynamic.Dynamic))
}

pub opaque type Task {
  Pending(fn() -> Task)
  Resolved(
    value: fn() -> Result(dynamic.Dynamic, diagnostic.Diagnostic),
    memory: fn() -> Result(webql_memory.Memory(Storage), diagnostic.Diagnostic),
    operator: fn() ->
      Result(Result(dynamic.Dynamic, dynamic.Dynamic), diagnostic.Diagnostic),
    batch: fn() -> Result(List(Task), diagnostic.Diagnostic),
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

pub fn memory() -> webql_memory.Memory(Storage) {
  webql_memory.Memory(
    new: memory,
    storage: Storage(dict.new()),
    get: get,
    set: set,
    merge: merge,
  )
}

pub fn ok(values: dict.Dict(String, dynamic.Dynamic)) -> Task {
  operator(Ok(encode(values)))
}

pub fn output(value: dynamic.Dynamic) -> Task {
  operator(Ok(value))
}

pub fn fail(message: dynamic.Dynamic) -> Task {
  operator(Error(message))
}

pub fn memory_task(
  result: Result(webql_memory.Memory(Storage), diagnostic.Diagnostic),
) -> Task {
  progress(result)
}

pub fn result(task: Task) -> Result(dynamic.Dynamic, diagnostic.Diagnostic) {
  value_result(task)
}

pub fn memory_result(
  task: Task,
) -> Result(webql_memory.Memory(Storage), diagnostic.Diagnostic) {
  case task {
    Pending(next) -> memory_result(next())
    Resolved(memory:, ..) -> memory()
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

// ENGINE HOOKS
// ============

fn run(next) {
  case next() {
    Ok(task) -> task
    Error(error) -> value(Error(error))
  }
}

fn start_plan(next) {
  Pending(fn() {
    case next() {
      Ok(#(initial, batches)) -> run_batches(initial, batches)
      Error(error) -> progress(Error(error))
    }
  })
}

fn finish_plan(task, next) {
  Pending(fn() {
    case memory_result(task) {
      Ok(memory) -> value(next(memory))
      Error(error) -> value(Error(error))
    }
  })
}

fn start_batch(next) {
  Pending(fn() { batch(next()) })
}

fn finish_batch(initial, task, merge) {
  Pending(fn() {
    case batch_result(task) {
      Ok(steps) -> run_steps(initial, steps, merge)
      Error(error) -> progress(Error(error))
    }
  })
}

fn start_step(next) {
  case next() {
    Ok(task) -> task
    Error(error) -> progress(Error(error))
  }
}

fn finish_step(task, next) {
  Pending(fn() {
    case operator_result(task) {
      Ok(result) -> progress(next(result))
      Error(error) -> progress(Error(error))
    }
  })
}

// TASK EXECUTION
// ==============

fn run_batches(initial, batches) {
  Pending(fn() {
    case batches {
      [] -> progress(Ok(initial))
      [batch, ..rest] -> {
        case memory_result(batch(initial)) {
          Ok(memory) -> run_batches(memory, rest)
          Error(error) -> progress(Error(error))
        }
      }
    }
  })
}

fn run_steps(initial, steps, merge) {
  Pending(fn() {
    case steps {
      [] -> progress(Ok(initial))
      [step, ..rest] -> {
        case memory_result(step) {
          Ok(memory) -> run_steps(merge(initial, memory), rest, merge)
          Error(error) -> progress(Error(error))
        }
      }
    }
  })
}

// TASK PROJECTIONS
// ================

fn value(result: Result(dynamic.Dynamic, diagnostic.Diagnostic)) -> Task {
  Resolved(
    value: fn() { result },
    memory: fn() { propagate_error(result) },
    operator: fn() {
      case result {
        Ok(value) -> Ok(Ok(value))
        Error(error) -> Error(error)
      }
    },
    batch: fn() { propagate_error(result) },
  )
}

fn progress(
  result: Result(webql_memory.Memory(Storage), diagnostic.Diagnostic),
) -> Task {
  Resolved(
    value: fn() { propagate_error(result) },
    memory: fn() { result },
    operator: fn() { propagate_error(result) },
    batch: fn() { propagate_error(result) },
  )
}

fn operator(result: Result(dynamic.Dynamic, dynamic.Dynamic)) -> Task {
  Resolved(
    value: fn() {
      case result {
        Ok(value) -> Ok(value)
        Error(message) -> Error(runtime_error(message))
      }
    },
    memory: fn() {
      case result {
        Error(message) -> Error(runtime_error(message))
        Ok(_value) -> panic
      }
    },
    operator: fn() { Ok(result) },
    batch: fn() { panic },
  )
}

fn batch(result: Result(List(Task), diagnostic.Diagnostic)) -> Task {
  Resolved(
    value: fn() { propagate_error(result) },
    memory: fn() { propagate_error(result) },
    operator: fn() { propagate_error(result) },
    batch: fn() { result },
  )
}

fn value_result(task: Task) -> Result(dynamic.Dynamic, diagnostic.Diagnostic) {
  case task {
    Pending(next) -> value_result(next())
    Resolved(value:, ..) -> value()
  }
}

fn operator_result(
  task: Task,
) -> Result(Result(dynamic.Dynamic, dynamic.Dynamic), diagnostic.Diagnostic) {
  case task {
    Pending(next) -> operator_result(next())
    Resolved(operator:, ..) -> operator()
  }
}

fn batch_result(task: Task) -> Result(List(Task), diagnostic.Diagnostic) {
  case task {
    Pending(next) -> batch_result(next())
    Resolved(batch:, ..) -> batch()
  }
}

fn propagate_error(result: Result(a, diagnostic.Diagnostic)) {
  case result {
    Error(error) -> Error(error)
    Ok(_value) -> panic
  }
}

fn runtime_error(message: dynamic.Dynamic) {
  diagnostic.Diagnostic(kind: diagnostic.RuntimeError(step: "", message:))
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
