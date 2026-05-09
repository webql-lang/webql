import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_plan
import webql/engine/interpreter/memory/kv
import webql/engine/interpreter/runtime as interpreter_runtime
import webql/resolution

pub fn interpret_plan_routes_parameter_to_output_test() {
  let p =
    plan.Plan(
      routes: [plan.Route(from: ["input"], to: ["output"])],
      batches: [],
    )

  let assert Ok(returns) =
    interpret_plan.interpret(
      p,
      kv.new(),
      runtime(),
      dict.from_list([#("input", dynamic.int(7))]),
    )
    |> unwrap()
  let returns = decode_inputs(returns)

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(7)
}

pub fn interpret_plan_routes_constant_to_output_test() {
  let p =
    plan.Plan(
      routes: [plan.Constant(value: dynamic.int(99), to: ["output"])],
      batches: [],
    )

  let assert Ok(returns) =
    interpret_plan.interpret(p, kv.new(), runtime(), dict.new())
    |> unwrap()
  let returns = decode_inputs(returns)

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn interpret_plan_runs_step_and_returns_output_test() {
  let step =
    plan.Step(
      name: "inc",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let inputs = decode_inputs(inputs)
          let assert Ok(n) = dict.get(inputs, "n")
          let assert Ok(n) = decode.run(n, decode.int)
          ok(dict.from_list([#("value", dynamic.int(n + 1))]))
        }),
      ),
    )

  let p =
    plan.Plan(
      routes: [
        plan.Route(from: ["input"], to: ["inc", "n"]),
        plan.Route(from: ["inc", "value"], to: ["output"]),
      ],
      batches: [plan.Batch(batch: [step])],
    )

  let assert Ok(returns) =
    interpret_plan.interpret(
      p,
      kv.new(),
      runtime(),
      dict.from_list([#("input", dynamic.int(4))]),
    )
    |> unwrap()
  let returns = decode_inputs(returns)

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(5)
}

pub fn interpret_plan_runs_multiple_batches_in_sequence_test() {
  let step_a =
    plan.Step(
      name: "double",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let inputs = decode_inputs(inputs)
          let assert Ok(x) = dict.get(inputs, "x")
          let assert Ok(x) = decode.run(x, decode.int)
          ok(dict.from_list([#("value", dynamic.int(x * 2))]))
        }),
      ),
    )

  let step_b =
    plan.Step(
      name: "inc",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let inputs = decode_inputs(inputs)
          let assert Ok(n) = dict.get(inputs, "n")
          let assert Ok(n) = decode.run(n, decode.int)
          ok(dict.from_list([#("value", dynamic.int(n + 1))]))
        }),
      ),
    )

  let p =
    plan.Plan(
      routes: [
        plan.Route(from: ["input"], to: ["double", "x"]),
        plan.Route(from: ["double", "value"], to: ["inc", "n"]),
        plan.Route(from: ["inc", "value"], to: ["output"]),
      ],
      batches: [
        plan.Batch(batch: [step_a]),
        plan.Batch(batch: [step_b]),
      ],
    )

  let assert Ok(returns) =
    interpret_plan.interpret(
      p,
      kv.new(),
      runtime(),
      dict.from_list([#("input", dynamic.int(3))]),
    )
    |> unwrap()
  let returns = decode_inputs(returns)

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(7)
}

pub fn interpret_plan_reports_missing_return_test() {
  let p =
    plan.Plan(
      routes: [plan.Route(from: ["missing"], to: ["output"])],
      batches: [],
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.MissingReturn(
    _message,
  ))) =
    interpret_plan.interpret(p, kv.new(), runtime(), dict.new())
    |> unwrap()
}

fn ok(values: dict.Dict(String, dynamic.Dynamic)) {
  values
  |> encode()
  |> Ok()
  |> resolution.Done()
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

fn runtime() {
  interpreter_runtime.Runtime(
    batches: run_batches,
    steps: run_steps,
    resolve: fn(resolution, next) { resolution.Done(next(unwrap(resolution))) },
    nested: continue,
    complete: continue,
  )
}

fn run_batches(initial, batches) {
  case batches {
    [] -> resolution.Done(Ok(initial))
    [batch, ..rest] -> {
      case unwrap(batch(initial)) {
        Ok(next) -> run_batches(next, rest)
        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn run_steps(initial, steps, merge) {
  case steps {
    [] -> resolution.Done(Ok(initial))
    [step, ..rest] -> {
      case unwrap(step) {
        Ok(next) -> run_steps(merge(initial, next), rest, merge)
        Error(error) -> resolution.Done(Error(error))
      }
    }
  }
}

fn continue(resolution, next) {
  case unwrap(resolution) {
    Ok(value) -> resolution.Done(next(value))
    Error(error) -> resolution.Done(Error(error))
  }
}

fn unwrap(resolution) {
  let assert resolution.Done(result) = resolution
  result
}
