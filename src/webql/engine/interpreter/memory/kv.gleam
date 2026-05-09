import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/engine/interpreter/memory

pub type Kv {
  Kv(values: dict.Dict(List(String), dynamic.Dynamic))
}

/// Creates a new memory instance constaining KV.
pub fn new() -> memory.Memory(Kv) {
  let storage = Kv(dict.new())
  memory.Memory(new:, storage:, get:, set:, merge:)
}

/// Gets a path from KV.
pub fn get(
  memory: memory.Memory(Kv),
  path: List(String),
) -> Result(dynamic.Dynamic, dynamic.Dynamic) {
  let memory.Memory(storage: kv, ..) = memory
  case dict.get(kv.values, path) {
    Ok(value) -> Ok(value)
    Error(_nil) -> Error(dynamic.nil())
  }
}

/// Inserts a value via a path into KV.
pub fn set(
  memory: memory.Memory(Kv),
  path: List(String),
  value: dynamic.Dynamic,
) -> memory.Memory(Kv) {
  let memory.Memory(storage: kv, ..) = memory
  memory.Memory(
    ..memory,
    storage: Kv(values: dict.insert(kv.values, path, value)),
  )
}

/// Merges two KV instances. Values from the second memory override the first.
pub fn merge(
  left: memory.Memory(Kv),
  right: memory.Memory(Kv),
) -> memory.Memory(Kv) {
  let values =
    dict.fold(
      right.storage.values,
      left.storage.values,
      fn(values, path, value) { dict.insert(values, path, value) },
    )

  memory.Memory(..left, storage: Kv(values:))
}
