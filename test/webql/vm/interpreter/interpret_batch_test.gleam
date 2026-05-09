import gleam/dict
import gleam/dynamic
import webql/document
import webql/vm/assembler/plan
import webql/vm/interpreter/diagnostic
import webql/vm/interpreter/interpret_batch
import webql/vm/interpreter/interpret_plan
import webql/vm/interpreter/memory/kv

pub fn interpret_batch_with_empty_batch_returns_progress_test() {
  let p = kv.new()
  let assert Ok(result) =
    interpret_batch.interpret([], [], p, interpret_plan.interpret)
  assert result == p
}

pub fn interpret_batch_short_circuits_on_error_test() {
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
    interpret_batch.interpret(
      [failing_step, ok_step],
      [],
      kv.new(),
      interpret_plan.interpret,
    )

  assert name == "fail"
  assert message == "oops"
}
