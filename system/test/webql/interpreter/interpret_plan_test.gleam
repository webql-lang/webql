import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/engine/basic
import webql/interpreter/interpret_plan
import webql/memory/kv
import webql/schema

pub fn interpret_plan_routes_parameter_to_output_test() {
  let engine = basic.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        edges: [
          plan.Edge(
            source: plan.Output(path: ["input"]),
            target: plan.Input(path: ["output"]),
          ),
        ],
        batches: [],
      ),
      kv.new(),
      engine,
      dynamic.properties([#(dynamic.string("input"), dynamic.int(7))]),
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Ok(outputs) = result
        let assert Ok(outputs) =
          decode.run(outputs, decode.dict(decode.string, decode.dynamic))
        let assert Ok(output) = dict.get(outputs, "output")
        assert decode.run(output, decode.int) == Ok(7)
        Ok(kv.new())
      }),
    )
  })
}

pub fn interpret_plan_runs_function_resolver_test() {
  let engine = basic.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        edges: [
          plan.Edge(
            source: plan.Output(path: ["input"]),
            target: plan.Input(path: ["inc", "n"]),
          ),
          plan.Edge(
            source: plan.Output(path: ["inc", "value"]),
            target: plan.Input(path: ["output"]),
          ),
        ],
        batches: [
          plan.Batch(steps: [
            plan.Step(
              name: "inc",
              node: plan.Node(
                schema.Resolver(resolver: fn(inputs) {
                  let assert Ok(inputs) =
                    decode.run(
                      inputs,
                      decode.dict(decode.string, decode.dynamic),
                    )
                  let assert Ok(raw_number) = dict.get(inputs, "n")
                  let assert Ok(number) = decode.run(raw_number, decode.int)

                  engine.finish_plan(
                    engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
                    fn(_memory) {
                      Ok(
                        dynamic.properties([
                          #(dynamic.string("value"), dynamic.int(number + 1)),
                        ]),
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
      dynamic.properties([#(dynamic.string("input"), dynamic.int(4))]),
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Ok(outputs) = result
        let assert Ok(outputs) =
          decode.run(outputs, decode.dict(decode.string, decode.dynamic))
        let assert Ok(output) = dict.get(outputs, "output")
        assert decode.run(output, decode.int) == Ok(5)
        Ok(kv.new())
      }),
    )
  })
}

pub fn interpret_plan_reports_missing_return_test() {
  let engine = basic.new()
  let task =
    interpret_plan.interpret(
      plan.Plan(
        edges: [
          plan.Edge(
            source: plan.Output(path: ["missing"]),
            target: plan.Input(path: ["output"]),
          ),
        ],
        batches: [],
      ),
      kv.new(),
      engine,
      dynamic.properties([]),
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Error(_) = result
        Ok(kv.new())
      }),
    )
  })
}
