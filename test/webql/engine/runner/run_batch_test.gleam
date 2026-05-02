import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress
import webql/engine/runner/run_batch
import webql/engine/runner/run_plan

pub fn run_batch_with_empty_batch_returns_progress_test() {
  let p = progress.new()
  let assert Ok(result) = run_batch.run([], [], p, run_plan.run)
  assert result == p
}

pub fn run_batch_runs_single_step_test() {
  let step =
    plan.Step(
      name: "produce",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          Ok(dict.from_list([#("value", dynamic.int(42))]))
        }),
      ),
    )

  let assert Ok(result) =
    run_batch.run([step], [], progress.new(), run_plan.run)

  let assert Ok(value) = progress.get_value(result, ["produce", "value"])
  assert decode.run(value, decode.int) == Ok(42)
}

pub fn run_batch_runs_multiple_steps_test() {
  let step_a =
    plan.Step(
      name: "a",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          Ok(dict.from_list([#("out", dynamic.int(1))]))
        }),
      ),
    )

  let step_b =
    plan.Step(
      name: "b",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          Ok(dict.from_list([#("out", dynamic.int(2))]))
        }),
      ),
    )

  let assert Ok(result) =
    run_batch.run([step_a, step_b], [], progress.new(), run_plan.run)

  let assert Ok(a) = progress.get_value(result, ["a", "out"])
  let assert Ok(b) = progress.get_value(result, ["b", "out"])
  assert decode.run(a, decode.int) == Ok(1)
  assert decode.run(b, decode.int) == Ok(2)
}

pub fn run_batch_short_circuits_on_error_test() {
  let failing_step =
    plan.Step(
      name: "fail",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) { Error("oops") }),
      ),
    )

  let ok_step =
    plan.Step(
      name: "ok",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) {
          Ok(dict.from_list([#("value", dynamic.int(1))]))
        }),
      ),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
    step: name,
    message:,
  ))) = run_batch.run([failing_step, ok_step], [], progress.new(), run_plan.run)

  assert name == "fail"
  assert message == "oops"
}
