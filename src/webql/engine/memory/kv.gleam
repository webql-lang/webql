import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/engine/memory

pub type Kv {
  Kv(values: dict.Dict(List(String), dynamic.Dynamic))
}

/// Creates a new memory instance constaining KV.
pub fn new() -> memory.Memory(Kv, Nil) {
  let storage = Kv(dict.new())
  memory.Memory(new:, storage:, get:, set:, encode:, decode:)
}

/// Gets a path from KV.
pub fn get(
  memory: memory.Memory(Kv, Nil),
  path: List(String),
) -> Result(dynamic.Dynamic, Nil) {
  let memory.Memory(storage: kv, ..) = memory
  dict.get(kv.values, path)
}

/// Inserts a value via a path into KV.
pub fn set(
  memory: memory.Memory(Kv, Nil),
  path: List(String),
  value: dynamic.Dynamic,
) -> memory.Memory(Kv, Nil) {
  let memory.Memory(storage: kv, ..) = memory
  memory.Memory(
    ..memory,
    storage: Kv(values: dict.insert(kv.values, path, value)),
  )
}

/// Encodes a KV store into a dynamic to be used by an external runtime.
pub fn encode(memory: memory.Memory(Kv, Nil)) -> dynamic.Dynamic {
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
  memory: memory.Memory(Kv, Nil),
  unknown: dynamic.Dynamic,
) -> Result(memory.Memory(Kv, Nil), List(decode.DecodeError)) {
  let schema = decode.dict(decode.list(decode.string), decode.dynamic)
  let values = decode.run(unknown, schema)

  case values {
    Ok(values) -> Ok(memory.Memory(..memory, storage: Kv(values:)))
    Error(error) -> Error(error)
  }
}
