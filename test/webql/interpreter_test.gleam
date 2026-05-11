import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/assembler/plan
import webql/document
import webql/interpreter
import webql/interpreter/diagnostic
import webql/interpreter/sandbox

fn add_resolver() {
  document.Resolver(resolver: fn(inputs) {
    let inputs = decode_inputs(inputs)
    let assert Ok(l) = dict.get(inputs, "l")
    let assert Ok(r) = dict.get(inputs, "r")
    let assert Ok(l) = decode.run(l, decode.int)
    let assert Ok(r) = decode.run(r, decode.int)

    sandbox.ok(dict.from_list([#("value", dynamic.int(l + r))]))
  })
}

fn identity_resolver() {
  document.Resolver(resolver: fn(inputs) {
    let inputs = decode_inputs(inputs)
    let assert Ok(value) = dict.get(inputs, "value")
    sandbox.ok(dict.from_list([#("value", value)]))
  })
}

pub fn interpreter_executes_plan_test() {
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
    |> interpreter.new()
    |> interpreter.interpret(
      sandbox.memory(),
      sandbox.engine(),
      encode(dict.from_list([#("input", dynamic.int(2))])),
    )
    |> sandbox.result()
  let outputs = decode_inputs(outputs)

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(3)
}

pub fn interpreter_executes_inline_plans_test() {
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
    |> interpreter.new()
    |> interpreter.interpret(
      sandbox.memory(),
      sandbox.engine(),
      encode(dict.from_list([#("input", dynamic.int(2))])),
    )
    |> sandbox.result()
  let outputs = decode_inputs(outputs)

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(3)
}

pub fn interpreter_keeps_inline_memory_isolated_test() {
  let inline_plan =
    plan.Plan(
      routes: [plan.Route(from: ["value"], to: ["normalized"])],
      batches: [],
    )

  let plan =
    plan.Plan(
      routes: [
        plan.Route(from: ["input"], to: ["normalize", "value"]),
        plan.Route(from: ["normalize", "normalized"], to: ["output"]),
        plan.Route(from: ["value"], to: ["outer"]),
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
    |> interpreter.new()
    |> interpreter.interpret(
      sandbox.memory(),
      sandbox.engine(),
      encode(
        dict.from_list([
          #("input", dynamic.int(2)),
          #("value", dynamic.int(100)),
        ]),
      ),
    )
    |> sandbox.result()
  let outputs = decode_inputs(outputs)

  let assert Ok(output) = dict.get(outputs, "output")
  let assert Ok(outer) = dict.get(outputs, "outer")

  assert decode.run(output, decode.int) == Ok(2)
  assert decode.run(outer, decode.int) == Ok(100)
}

pub fn interpreter_reports_missing_inputs_test() {
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
    |> interpreter.new()
    |> interpreter.interpret(
      sandbox.memory(),
      sandbox.engine(),
      encode(dict.new()),
    )
    |> sandbox.result()
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.MissingStepInput(
        step: "identity",
        message: dynamic.nil(),
      )),
    )
}

pub fn interpreter_reports_missing_outputs_test() {
  let plan =
    plan.Plan(
      routes: [plan.Route(from: ["missing"], to: ["output"])],
      batches: [],
    )

  assert plan
    |> interpreter.new()
    |> interpreter.interpret(
      sandbox.memory(),
      sandbox.engine(),
      encode(dict.new()),
    )
    |> sandbox.result()
    == Error(
      diagnostic.Diagnostic(
        kind: diagnostic.MissingReturn(message: dynamic.nil()),
      ),
    )
}

fn encode(values: dict.Dict(String, dynamic.Dynamic)) {
  values
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(key, value) = entry
    #(dynamic.string(key), value)
  })
  |> dynamic.properties()
}

fn decode_inputs(inputs: dynamic.Dynamic) {
  let assert Ok(inputs) =
    decode.run(inputs, decode.dict(decode.string, decode.dynamic))
  inputs
}
