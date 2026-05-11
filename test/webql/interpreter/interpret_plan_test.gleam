import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/document
import webql/engine/transient
import webql/interpreter/interpret_plan
import webql/memory/kv

pub fn interpret_plan_routes_parameter_to_output_test() {
  let engine = transient.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        routes: [plan.Route(from: ["input"], to: ["output"])],
        batches: [],
      ),
      kv.new(),
      engine,
      [#(dynamic.string("input"), dynamic.int(7))]
        |> dynamic.properties(),
    )

  engine.finish_step(task, fn(result) {
    let assert Ok(outputs) = result
    let assert Ok(outputs) =
      decode.run(outputs, decode.dict(decode.string, decode.dynamic))
    let assert Ok(output) = dict.get(outputs, "output")
    assert decode.run(output, decode.int) == Ok(7)
    Ok(kv.new())
  })
}

pub fn interpret_plan_runs_function_resolver_test() {
  let engine = transient.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        routes: [
          plan.Route(from: ["input"], to: ["inc", "n"]),
          plan.Route(from: ["inc", "value"], to: ["output"]),
        ],
        batches: [
          plan.Batch(batch: [
            plan.Step(
              name: "inc",
              resolver: plan.FunctionResolver(
                document.Resolver(resolver: fn(inputs) {
                  let assert Ok(inputs) =
                    decode.run(inputs, decode.dict(decode.string, decode.dynamic))
                  let assert Ok(n) = dict.get(inputs, "n")
                  let assert Ok(n) = decode.run(n, decode.int)

                  engine.finish_plan(
                    engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
                    fn(_memory) {
                      Ok(
                        [#(dynamic.string("value"), dynamic.int(n + 1))]
                        |> dynamic.properties(),
                      )
                    },
                  )
                }),
              ),
            ),
          ]),
        ],
      ),
      kv.new(),
      engine,
      [#(dynamic.string("input"), dynamic.int(4))]
        |> dynamic.properties(),
    )

  engine.finish_step(task, fn(result) {
    let assert Ok(outputs) = result
    let assert Ok(outputs) =
      decode.run(outputs, decode.dict(decode.string, decode.dynamic))
    let assert Ok(output) = dict.get(outputs, "output")
    assert decode.run(output, decode.int) == Ok(5)
    Ok(kv.new())
  })
}

pub fn interpret_plan_reports_missing_return_test() {
  let engine = transient.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        routes: [plan.Route(from: ["missing"], to: ["output"])],
        batches: [],
      ),
      kv.new(),
      engine,
      [] |> dynamic.properties(),
    )

  engine.finish_step(task, fn(result) {
    let assert Error(_) = result
    Ok(kv.new())
  })
}
