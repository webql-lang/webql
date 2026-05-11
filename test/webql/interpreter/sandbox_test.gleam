import gleam/dynamic
import gleam/dynamic/decode
import webql/interpreter/sandbox

pub fn sandbox_memory_gets_set_value_by_path_test() {
  let memory =
    sandbox.set(sandbox.memory(), ["user", "name"], dynamic.string("John Doe"))

  let assert Ok(value) = sandbox.get(memory, ["user", "name"])
  assert decode.run(value, decode.string) == Ok("John Doe")
}

pub fn sandbox_memory_reports_missing_path_test() {
  assert sandbox.get(sandbox.memory(), ["missing"]) == Error(dynamic.nil())
}

pub fn sandbox_memory_merge_combines_values_test() {
  let left =
    sandbox.set(sandbox.memory(), ["user", "name"], dynamic.string("John Doe"))
  let right = sandbox.set(sandbox.memory(), ["user", "age"], dynamic.int(30))

  let merged = sandbox.merge(left, right)

  let assert Ok(name) = sandbox.get(merged, ["user", "name"])
  let assert Ok(age) = sandbox.get(merged, ["user", "age"])

  assert decode.run(name, decode.string) == Ok("John Doe")
  assert decode.run(age, decode.int) == Ok(30)
}

pub fn sandbox_memory_merge_uses_right_value_on_conflict_test() {
  let left = sandbox.set(sandbox.memory(), ["count"], dynamic.int(1))
  let right = sandbox.set(sandbox.memory(), ["count"], dynamic.int(2))

  let merged = sandbox.merge(left, right)

  let assert Ok(count) = sandbox.get(merged, ["count"])
  assert decode.run(count, decode.int) == Ok(2)
}
