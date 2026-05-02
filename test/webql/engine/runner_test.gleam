import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/plan
import webql/engine/runner
import webql/engine/runner/diagnostic

fn add_resolver() {
  document.Resolver(resolver: fn(inputs) {
    let assert Ok(l) = dict.get(inputs, "l")
    let assert Ok(r) = dict.get(inputs, "r")
    let assert Ok(l) = decode.run(l, decode.int)
    let assert Ok(r) = decode.run(r, decode.int)

    Ok(dict.from_list([#("value", dynamic.int(l + r))]))
  })
}

fn identity_resolver() {
  document.Resolver(resolver: fn(inputs) {
    let assert Ok(value) = dict.get(inputs, "value")
    Ok(dict.from_list([#("value", value)]))
  })
}

pub fn runner_executes_plan_test() {
  let plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["input"], to: ["add", "l"]),
        plan.Constant(value: dynamic.int(1), to: ["add", "r"]),
        plan.Route(from: ["add", "value"], to: ["output"]),
      ],
      batches: [
        plan.Batch(batch: [
          plan.Step(
            name: "add",
            resolver: plan.FunctionResolver(function: add_resolver()),
          ),
        ]),
      ],
    )

  let assert Ok(outputs) =
    plan
    |> runner.new()
    |> runner.run(dict.from_list([#("input", dynamic.int(2))]))

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(3)
}

pub fn runner_routes_until_values_settle_test() {
  let plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["middle"], to: ["output"]),
        plan.Route(from: ["input"], to: ["middle"]),
      ],
      batches: [],
    )

  let assert Ok(outputs) =
    plan
    |> runner.new()
    |> runner.run(dict.from_list([#("input", dynamic.int(1))]))

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(1)
}

pub fn runner_executes_inline_plans_test() {
  let inline_plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["value"], to: ["add", "l"]),
        plan.Constant(value: dynamic.int(1), to: ["add", "r"]),
        plan.Route(from: ["add", "value"], to: ["normalized"]),
      ],
      batches: [
        plan.Batch(batch: [
          plan.Step(
            name: "add",
            resolver: plan.FunctionResolver(function: add_resolver()),
          ),
        ]),
      ],
    )

  let plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["input"], to: ["normalize", "value"]),
        plan.Route(from: ["normalize", "normalized"], to: ["output"]),
      ],
      batches: [
        plan.Batch(batch: [
          plan.Step(
            name: "normalize",
            resolver: plan.InlineResolver(plan: inline_plan),
          ),
        ]),
      ],
    )

  let assert Ok(outputs) =
    plan
    |> runner.new()
    |> runner.run(dict.from_list([#("input", dynamic.int(2))]))

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(3)
}

pub fn runner_reports_missing_inputs_test() {
  let plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["missing"], to: ["identity", "value"]),
        plan.Route(from: ["identity", "value"], to: ["output"]),
      ],
      batches: [
        plan.Batch(batch: [
          plan.Step(
            name: "identity",
            resolver: plan.FunctionResolver(function: identity_resolver()),
          ),
        ]),
      ],
    )

  assert plan
    |> runner.new()
    |> runner.run(dict.new())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
        step: "identity",
        input: "value",
      )),
    )
}

pub fn runner_reports_missing_outputs_test() {
  let plan =
    plan.Plan(
      routes: [plan.Route(from: ["missing"], to: ["output"])],
      batches: [],
    )

  assert plan
    |> runner.new()
    |> runner.run(dict.new())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.MissingReturn(output: "output")),
    )
}
