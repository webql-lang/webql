import gleam/dynamic

pub type New(storage) =
  fn() -> Memory(storage)

pub type Get(storage) =
  fn(Memory(storage), List(String)) -> Result(dynamic.Dynamic, dynamic.Dynamic)

pub type Set(storage) =
  fn(Memory(storage), List(String), dynamic.Dynamic) -> Memory(storage)

pub type Merge(storage) =
  fn(Memory(storage), Memory(storage)) -> Memory(storage)

pub type Memory(storage) {
  Memory(
    new: New(storage),
    storage: storage,
    get: Get(storage),
    set: Set(storage),
    merge: Merge(storage),
  )
}
