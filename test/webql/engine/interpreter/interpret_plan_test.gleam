import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/assembler/plan
import webql/engine/interpreter/diagnostic
import webql/engine/interpreter/interpret_plan
import webql/engine/interpreter/memory/kv

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
      dict.from_list([#("input", dynamic.int(7))]),
    )

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(7)
}

pub fn interpret_plan_routes_constant_to_output_test() {
  let p =
    plan.Plan(
      routes: [plan.Constant(value: dynamic.int(99), to: ["output"])],
      batches: [],
    )

  let assert Ok(returns) = interpret_plan.interpret(p, kv.new(), dict.new())

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(99)
}

pub fn interpret_plan_runs_step_and_returns_output_test() {
  let step =
    plan.Step(
      name: "inc",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let assert Ok(n) = dict.get(inputs, "n")
          let assert Ok(n) = decode.run(n, decode.int)
          Ok(dict.from_list([#("value", dynamic.int(n + 1))]))
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
      dict.from_list([#("input", dynamic.int(4))]),
    )

  let assert Ok(value) = dict.get(returns, "output")
  assert decode.run(value, decode.int) == Ok(5)
}

pub fn interpret_plan_runs_multiple_batches_in_sequence_test() {
  let step_a =
    plan.Step(
      name: "double",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let assert Ok(x) = dict.get(inputs, "x")
          let assert Ok(x) = decode.run(x, decode.int)
          Ok(dict.from_list([#("value", dynamic.int(x * 2))]))
        }),
      ),
    )

  let step_b =
    plan.Step(
      name: "inc",
      resolver: plan.FunctionResolver(
        document.Resolver(resolver: fn(inputs) {
          let assert Ok(n) = dict.get(inputs, "n")
          let assert Ok(n) = decode.run(n, decode.int)
          Ok(dict.from_list([#("value", dynamic.int(n + 1))]))
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
      dict.from_list([#("input", dynamic.int(3))]),
    )

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
  ))) = interpret_plan.interpret(p, kv.new(), dict.new())
}
