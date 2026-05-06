import gleam/dict
import gleam/dynamic
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
