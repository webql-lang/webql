import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/system/plan
import webql/engine/system/progress
import webql/engine/system/traverser/diagnostic
import webql/engine/system/traverser/traverse_batch
import webql/engine/system/traverser/traverse_plan

pub fn traverse_batch_with_empty_batch_returns_progress_test() {
  let p = progress.new()
  let assert Ok(result) =
    traverse_batch.traverse([], [], p, traverse_plan.traverse)
  assert result == p
}

pub fn traverse_batch_short_circuits_on_error_test() {
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
  ))) =
    traverse_batch.traverse(
      [failing_step, ok_step],
      [],
      progress.new(),
      traverse_plan.traverse,
    )

  assert name == "fail"
  assert message == "oops"
}
