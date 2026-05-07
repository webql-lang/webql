import gleam/dynamic

pub type Memory(a, b) {
  Memory(
    new: fn() -> a,
    get: fn(a, List(String)) -> dynamic.Dynamic,
    set: fn(a, List(String), dynamic.Dynamic) -> a,
    encode: fn(dynamic.Dynamic) -> a,
    decode: fn(b) -> Result(dynamic.Dynamic, b),
  )
}
