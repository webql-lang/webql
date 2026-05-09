import webql/document
import webql/vm/assembler/plan
import webql/vm/interpreter/diagnostic
import webql/vm/interpreter/interpret_plan
import webql/vm/interpreter/interpret_step
import webql/vm/interpreter/memory/kv

pub fn interpret_step_reports_runtime_error_test() {
  let step =
    plan.Step(
      name: "fail",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(_inputs) { Error("oops") }),
      ),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.RuntimeError(
    step: name,
    message:,
  ))) = interpret_step.interpret(step, [], kv.new(), interpret_plan.interpret)

  assert name == "fail"
  assert message == "oops"
}

pub fn interpret_step_reports_missing_step_input_test() {
  let step =
    plan.Step(
      name: "op",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) { Ok(inputs) }),
      ),
    )

  let routes = [plan.Route(from: ["source"], to: ["op", "x"])]

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
    step: s,
  ))) =
    interpret_step.interpret(step, routes, kv.new(), interpret_plan.interpret)

  assert s == "op"
}
