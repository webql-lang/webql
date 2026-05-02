import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/engine/runner/progress

pub fn progress_adds_root_values_test() {
  let progress =
    progress.new()
    |> progress.add_values([], dict.from_list([#("user_id", dynamic.int(1))]))

  let assert Ok(value) = progress.get_value(progress, ["user_id"])
  assert decode.run(value, decode.int) == Ok(1)
}

pub fn progress_adds_values_test() {
  let progress =
    progress.new()
    |> progress.add_value(["user", "id"], dynamic.int(1))

  let assert Ok(value) = progress.get_value(progress, ["user", "id"])
  assert decode.run(value, decode.int) == Ok(1)
}

pub fn progress_adds_nested_values_test() {
  let progress =
    progress.new()
    |> progress.add_values(["user"], dict.from_list([#("id", dynamic.int(1))]))

  let assert Ok(value) = progress.get_value(progress, ["user", "id"])
  assert decode.run(value, decode.int) == Ok(1)
}
