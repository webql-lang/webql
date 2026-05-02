import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/plan
import webql/engine/runner/diagnostic
import webql/engine/runner/progress
import webql/engine/runner/run_plan
import webql/engine/runner/run_step

pub fn run_step_runs_function_resolver_test() {
  let step =
    plan.Step(
      name: "double",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let assert Ok(x) = dict.get(inputs, "x")
          let assert Ok(x) = decode.run(x, decode.int)
          Ok(dict.from_list([#("result", dynamic.int(x * 2))]))
        }),
      ),
    )

  let routes = [plan.Route(from: ["input"], to: ["double", "x"])]

  let p =
    progress.new()
    |> progress.add_value(["double", "x"], dynamic.int(5))

  let assert Ok(result) = run_step.run(step, routes, p, run_plan.run)

  let assert Ok(value) = progress.get_value(result, ["double", "result"])
  assert decode.run(value, decode.int) == Ok(10)
}

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
    input: i,
  ))) = run_step.run(step, routes, progress.new(), run_plan.run)

  assert s == "op"
  assert i == "x"
}

pub fn run_step_runs_inline_resolver_test() {
  let inner_plan =
    plan.Plan(
      routes: [plan.Constant(value: dynamic.int(42), to: ["result"])],
      batches: [],
    )

  let step =
    plan.Step(name: "sub", resolver: plan.InlineResolver(plan: inner_plan))

  let assert Ok(result) = run_step.run(step, [], progress.new(), run_plan.run)

  let assert Ok(value) = progress.get_value(result, ["sub", "result"])
  assert decode.run(value, decode.int) == Ok(42)
}
