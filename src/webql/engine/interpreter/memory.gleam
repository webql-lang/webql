import gleam/dynamic
import gleam/dynamic/decode

pub type Memory(storage) {
  Memory(
    new: fn() -> Memory(storage),
    storage: storage,
    get: fn(Memory(storage), List(String)) ->
      Result(dynamic.Dynamic, dynamic.Dynamic),
    set: fn(Memory(storage), List(String), dynamic.Dynamic) -> Memory(storage),
    encode: fn(Memory(storage)) -> dynamic.Dynamic,
    decode: fn(Memory(storage), dynamic.Dynamic) ->
      Result(Memory(storage), List(decode.DecodeError)),
  )
}
