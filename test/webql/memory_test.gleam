import gleam/dynamic
import gleam/dynamic/decode
import webql/memory

pub fn new_returns_empty_memory_test() {
  let kv = memory.new()

  assert memory.get(kv, ["missing"]) == Error(dynamic.nil())
}

pub fn set_stores_value_at_path_test() {
  let kv = memory.set(memory.new(), ["user", "name"], dynamic.string("Ada"))

  let assert Ok(value) = memory.get(kv, ["user", "name"])
  assert decode.run(value, decode.string) == Ok("Ada")
}

pub fn set_replaces_value_at_existing_path_test() {
  let kv =
    memory.new()
    |> memory.set(["value"], dynamic.int(1))
    |> memory.set(["value"], dynamic.int(2))

  let assert Ok(value) = memory.get(kv, ["value"])
  assert decode.run(value, decode.int) == Ok(2)
}

pub fn merge_keeps_left_paths_test() {
  let left = memory.set(memory.new(), ["left"], dynamic.int(1))
  let right = memory.set(memory.new(), ["right"], dynamic.int(2))
  let merged = memory.merge(left, right)

  assert memory.get(merged, ["left"]) == Ok(dynamic.int(1))
  assert memory.get(merged, ["right"]) == Ok(dynamic.int(2))
}

pub fn merge_uses_right_value_for_conflicting_paths_test() {
  let left = memory.set(memory.new(), ["value"], dynamic.int(1))
  let right = memory.set(memory.new(), ["value"], dynamic.int(2))
  let merged = memory.merge(left, right)

  assert memory.get(merged, ["value"]) == Ok(dynamic.int(2))
}

pub fn encode_can_be_decoded_back_into_memory_test() {
  let kv =
    memory.new()
    |> memory.set(["a"], dynamic.int(1))
    |> memory.set(["nested", "value"], dynamic.string("ok"))

  let assert Ok(decoded) = memory.decode(memory.new(), memory.encode(kv))

  assert memory.get(decoded, ["a"]) == Ok(dynamic.int(1))

  let assert Ok(value) = memory.get(decoded, ["nested", "value"])
  assert decode.run(value, decode.string) == Ok("ok")
}

pub fn decode_replaces_existing_storage_test() {
  let original = memory.set(memory.new(), ["old"], dynamic.int(1))
  let replacement = memory.set(memory.new(), ["new"], dynamic.int(2))

  let assert Ok(decoded) = memory.decode(original, memory.encode(replacement))

  assert memory.get(decoded, ["old"]) == Error(dynamic.nil())
  assert memory.get(decoded, ["new"]) == Ok(dynamic.int(2))
}

pub fn decode_returns_errors_for_invalid_memory_test() {
  let assert Error(errors) = memory.decode(memory.new(), dynamic.int(1))

  assert errors != []
}
