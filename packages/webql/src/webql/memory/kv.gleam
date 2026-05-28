import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/memory

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

/// Merges two KV stores, using right-hand values when paths conflict.
pub fn merge(
  left: memory.Memory(Kv),
  right: memory.Memory(Kv),
) -> memory.Memory(Kv) {
  let memory.Memory(storage: left_kv, ..) = left
  let memory.Memory(storage: right_kv, ..) = right

  let values =
    dict.fold(right_kv.values, left_kv.values, fn(values, path, value) {
      dict.insert(values, path, value)
    })

  memory.Memory(..left, storage: Kv(values:))
}

/// Encodes a KV store into a dynamic to be used by an external runtime.
pub fn encode(memory: memory.Memory(Kv)) -> dynamic.Dynamic {
  let memory.Memory(storage: kv, ..) = memory

  kv.values
  |> dict.to_list()
  |> list.map(fn(input) {
    let #(path, value) = input
    let key =
      path
      |> list.map(dynamic.string)
      |> dynamic.array()

    #(key, value)
  })
  |> dynamic.properties()
}

/// Decodes a dynamic (ie. a Erlang map or JS object) by coverting it into a KV value.
pub fn decode(
  memory: memory.Memory(Kv),
  unknown: dynamic.Dynamic,
) -> Result(memory.Memory(Kv), List(decode.DecodeError)) {
  let schema = decode.dict(decode.list(decode.string), decode.dynamic)
  let values = decode.run(unknown, schema)

  case values {
    Ok(values) -> Ok(memory.Memory(..memory, storage: Kv(values:)))
    Error(error) -> Error(error)
  }
}
