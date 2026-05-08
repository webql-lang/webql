import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/engine/memory/kv
import webql/engine/system/plan
import webql/engine/system/progress

pub fn progress_gets_constant_returns_test() {
  let assert Ok(returns) =
    progress.get_returns(kv.new(), [
      plan.Constant(value: dynamic.int(99), to: ["output"]),
    ])

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn progress_reports_missing_route_return_test() {
  let assert Error(Nil) =
    progress.get_returns(kv.new(), [
      plan.Route(from: ["missing"], to: ["output"]),
    ])
}
