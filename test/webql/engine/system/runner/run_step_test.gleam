import webql/document
import webql/engine/memory/kv
import webql/engine/system/plan
import webql/engine/system/traverser/diagnostic
import webql/engine/system/traverser/traverse_plan
import webql/engine/system/traverser/traverse_step

pub fn traverse_step_reports_runtime_error_test() {
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
  ))) = traverse_step.traverse(step, [], kv.new(), traverse_plan.traverse)

  assert name == "fail"
  assert message == "oops"
}

pub fn traverse_step_reports_missing_step_input_test() {
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
  ))) = traverse_step.traverse(step, routes, kv.new(), traverse_plan.traverse)

  assert s == "op"
}
