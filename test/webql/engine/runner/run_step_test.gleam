import webql/document
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress
import webql/engine/runner/run_plan
import webql/engine/runner/run_step

pub fn run_step_reports_runtime_error_test() {
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
  ))) = run_step.run(step, [], progress.new(), run_plan.run)

  assert name == "fail"
  assert message == "oops"
}

pub fn run_step_reports_missing_step_input_test() {
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
  ))) = run_step.run(step, routes, progress.new(), run_plan.run)

  assert s == "op"
}
