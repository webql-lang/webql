import gleam/dynamic
import gleam/dynamic/decode
import webql/engine/memory/kv

pub fn kv_gets_set_value_by_path_test() {
  let memory = kv.set(kv.new(), ["user", "name"], dynamic.string("Aydan"))

  let assert Ok(value) = kv.get(memory, ["user", "name"])
  assert decode.run(value, decode.string) == Ok("Aydan")
}

pub fn kv_reports_missing_path_test() {
  assert kv.get(kv.new(), ["missing"]) == Error(Nil)
}

pub fn kv_decode_restores_values_test() {
  let memory = kv.set(kv.new(), ["count"], dynamic.int(3))

  let encoded = kv.encode(memory)
  let assert Ok(decoded) = kv.decode(kv.new(), encoded)
  let assert Ok(value) = kv.get(decoded, ["count"])

  assert decode.run(value, decode.int) == Ok(3)
}
