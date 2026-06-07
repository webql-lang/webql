import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list

pub type New(store) =
  fn() -> Memory(store)

pub type Get(store) =
  fn(Memory(store), List(String)) -> Result(dynamic.Dynamic, dynamic.Dynamic)

pub type Set(store) =
  fn(Memory(store), List(String), dynamic.Dynamic) -> Memory(store)

pub type Merge(store) =
  fn(Memory(store), Memory(store)) -> Memory(store)

pub type Memory(store) {
  Memory(
    new: New(store),
    store: store,
    get: Get(store),
    set: Set(store),
    merge: Merge(store),
  )
}

pub opaque type Store {
  Store(dict.Dict(List(String), dynamic.Dynamic))
}

/// Creates a new memory instance constaining KV.
pub fn new() -> Memory(Store) {
  let store = Store(dict.new())
  Memory(new:, store:, get:, set:, merge:)
}

/// Gets a path from KV.
pub fn get(
  memory: Memory(Store),
  path: List(String),
) -> Result(dynamic.Dynamic, dynamic.Dynamic) {
  let Memory(store: Store(store), ..) = memory
  case dict.get(store, path) {
    Ok(value) -> Ok(value)
    Error(_nil) -> Error(dynamic.nil())
  }
}

/// Inserts a value via a path into KV.
pub fn set(
  memory: Memory(Store),
  path: List(String),
  value: dynamic.Dynamic,
) -> Memory(Store) {
  let Memory(store: Store(store), ..) = memory
  Memory(..memory, store: Store(dict.insert(store, path, value)))
}

/// Merges two KV stores, using right-hand values when paths conflict.
pub fn merge(left: Memory(Store), right: Memory(Store)) -> Memory(Store) {
  let Memory(store: Store(left_store), ..) = left
  let Memory(store: Store(right_store), ..) = right

  let values =
    dict.fold(right_store, left_store, fn(values, path, value) {
      dict.insert(values, path, value)
    })

  Memory(..left, store: Store(values))
}

/// Encodes a KV store into a dynamic to be used by an external runtime.
pub fn encode(memory: Memory(Store)) -> dynamic.Dynamic {
  let Memory(store: Store(store), ..) = memory

  store
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
  memory: Memory(Store),
  unknown: dynamic.Dynamic,
) -> Result(Memory(Store), List(decode.DecodeError)) {
  let schema = decode.dict(decode.list(decode.string), decode.dynamic)
  let store = decode.run(unknown, schema)

  case store {
    Ok(values) -> Ok(Memory(..memory, store: Store(values)))
    Error(error) -> Error(error)
  }
}
