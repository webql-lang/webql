import gleam/dynamic
import gleam/dynamic/decode
import webql/memory/kv

pub fn new_returns_empty_memory_test() {
  let kv = kv.new()

  assert kv.get(kv, ["missing"]) == Error(dynamic.nil())
}

pub fn set_stores_value_at_path_test() {
  let kv = kv.set(kv.new(), ["user", "name"], dynamic.string("Ada"))

  let assert Ok(value) = kv.get(kv, ["user", "name"])
  assert decode.run(value, decode.string) == Ok("Ada")
}

pub fn set_replaces_value_at_existing_path_test() {
  let kv =
    kv.new()
    |> kv.set(["value"], dynamic.int(1))
    |> kv.set(["value"], dynamic.int(2))

  let assert Ok(value) = kv.get(kv, ["value"])
  assert decode.run(value, decode.int) == Ok(2)
}

pub fn merge_keeps_left_paths_test() {
  let left = kv.set(kv.new(), ["left"], dynamic.int(1))
  let right = kv.set(kv.new(), ["right"], dynamic.int(2))
  let merged = kv.merge(left, right)

  assert kv.get(merged, ["left"]) == Ok(dynamic.int(1))
  assert kv.get(merged, ["right"]) == Ok(dynamic.int(2))
}

pub fn merge_uses_right_value_for_conflicting_paths_test() {
  let left = kv.set(kv.new(), ["value"], dynamic.int(1))
  let right = kv.set(kv.new(), ["value"], dynamic.int(2))
  let merged = kv.merge(left, right)

  assert kv.get(merged, ["value"]) == Ok(dynamic.int(2))
}

pub fn encode_can_be_decoded_back_into_memory_test() {
  let kv =
    kv.new()
    |> kv.set(["a"], dynamic.int(1))
    |> kv.set(["nested", "value"], dynamic.string("ok"))

  let assert Ok(decoded) = kv.decode(kv.new(), kv.encode(kv))

  assert kv.get(decoded, ["a"]) == Ok(dynamic.int(1))

  let assert Ok(value) = kv.get(decoded, ["nested", "value"])
  assert decode.run(value, decode.string) == Ok("ok")
}

pub fn decode_replaces_existing_storage_test() {
  let original = kv.set(kv.new(), ["old"], dynamic.int(1))
  let replacement = kv.set(kv.new(), ["new"], dynamic.int(2))

  let assert Ok(decoded) = kv.decode(original, kv.encode(replacement))

  assert kv.get(decoded, ["old"]) == Error(dynamic.nil())
  assert kv.get(decoded, ["new"]) == Ok(dynamic.int(2))
}

pub fn decode_returns_errors_for_invalid_memory_test() {
  let assert Error(errors) = kv.decode(kv.new(), dynamic.int(1))

  assert errors != []
}
