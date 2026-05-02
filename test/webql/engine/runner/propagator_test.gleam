import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/engine/plan
import webql/engine/runner/progress
import webql/engine/runner/propagator

pub fn register_route_routes_available_values_test() {
  let progress =
    progress.new()
    |> progress.add_value(["input"], dynamic.int(1))
    |> propagator.propagate([
      plan.Route(from: ["input"], to: ["node", "value"]),
    ])

  let assert Ok(value) = progress.get_value(progress, ["node", "value"])
  assert decode.run(value, decode.int) == Ok(1)
}

pub fn register_route_routes_constants_test() {
  let progress =
    propagator.propagate(progress.new(), [
      plan.Constant(value: dynamic.int(1), to: ["node", "value"]),
    ])

  let assert Ok(value) = progress.get_value(progress, ["node", "value"])
  assert decode.run(value, decode.int) == Ok(1)
}

pub fn register_route_routes_until_values_settle_test() {
  let progress =
    progress.new()
    |> progress.add_values([], dict.from_list([#("input", dynamic.int(1))]))
    |> propagator.propagate([
      plan.Route(from: ["middle"], to: ["output"]),
      plan.Route(from: ["input"], to: ["middle"]),
    ])

  let assert Ok(value) = progress.get_value(progress, ["input"])
  assert decode.run(value, decode.int) == Ok(1)
}

pub fn register_route_ignores_missing_values_test() {
  let progress =
    propagator.propagate(progress.new(), [
      plan.Route(from: ["missing"], to: ["output"]),
    ])

  assert progress.get_value(progress, ["output"]) == Error(Nil)
}
