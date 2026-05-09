import gleam/dynamic
import gleam/dynamic/decode
import webql/engine/interpreter/memory/kv

pub fn kv_gets_set_value_by_path_test() {
  let memory = kv.set(kv.new(), ["user", "name"], dynamic.string("Aydan"))

  let assert Ok(value) = kv.get(memory, ["user", "name"])
  assert decode.run(value, decode.string) == Ok("Aydan")
}

pub fn kv_reports_missing_path_test() {
  assert kv.get(kv.new(), ["missing"]) == Error(dynamic.nil())
}

pub fn kv_merge_combines_values_test() {
  let left = kv.set(kv.new(), ["user", "name"], dynamic.string("Aydan"))
  let right = kv.set(kv.new(), ["user", "age"], dynamic.int(30))

  let merged = kv.merge(left, right)

  let assert Ok(name) = kv.get(merged, ["user", "name"])
  let assert Ok(age) = kv.get(merged, ["user", "age"])

  assert decode.run(name, decode.string) == Ok("Aydan")
  assert decode.run(age, decode.int) == Ok(30)
}

pub fn kv_merge_uses_right_value_on_conflict_test() {
  let left = kv.set(kv.new(), ["count"], dynamic.int(1))
  let right = kv.set(kv.new(), ["count"], dynamic.int(2))

  let merged = kv.merge(left, right)

  let assert Ok(count) = kv.get(merged, ["count"])
  assert decode.run(count, decode.int) == Ok(2)
}
