import gleam/dynamic
import gleam/dynamic/decode

pub type Memory(a, b) {
  Memory(
    new: fn() -> Memory(a, b),
    storage: a,
    get: fn(Memory(a, b), List(String)) -> Result(dynamic.Dynamic, b),
    set: fn(Memory(a, b), List(String), dynamic.Dynamic) -> Memory(a, b),
    encode: fn(Memory(a, b)) -> dynamic.Dynamic,
    decode: fn(Memory(a, b), dynamic.Dynamic) ->
      Result(Memory(a, b), List(decode.DecodeError)),
  )
}
