import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/interpreter/progress
import webql/interpreter/sandbox

pub fn progress_gets_constant_returns_test() {
  let assert Ok(returns) =
    progress.get_returns(sandbox.memory(), [
      plan.Constant(value: dynamic.int(99), to: ["output"]),
    ])

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn progress_reports_missing_route_return_test() {
  let assert Error(message) =
    progress.get_returns(sandbox.memory(), [
      plan.Route(from: ["missing"], to: ["output"]),
    ])

  assert message == dynamic.nil()
}
