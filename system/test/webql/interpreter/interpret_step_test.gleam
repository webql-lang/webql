import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/document
import webql/engine/basic
import webql/interpreter/interpret_plan
import webql/interpreter/interpret_step
import webql/interpreter/progress
import webql/memory/kv

pub fn interpret_step_runs_function_resolver_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(4))
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "inc",
        resolver: plan.FunctionResolver(
          document.Resolver(resolver: fn(inputs) {
            let assert Ok(inputs) =
              decode.run(inputs, decode.dict(decode.string, decode.dynamic))
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
      [plan.Route(from: ["input"], to: ["inc", "n"])],
      engine,
      memory,
      interpret_plan.interpret,
    )

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        let assert Ok(output) = kv.get(memory, ["inc", "value"])
        assert decode.run(output, decode.int) == Ok(5)
        Ok(dynamic.nil())
      }),
    )
  })
}

pub fn interpret_step_reports_missing_input_test() {
  let engine = basic.new()
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "op",
        resolver: plan.FunctionResolver(
          document.Resolver(resolver: fn(_inputs) {
            engine.finish_plan(
              engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
              fn(_memory) { Ok(dynamic.nil()) },
            )
          }),
        ),
      ),
      [plan.Route(from: ["missing"], to: ["op", "value"])],
      engine,
      kv.new(),
      interpret_plan.interpret,
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

pub fn interpret_step_reports_invalid_output_test() {
  let engine = basic.new()
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "invalid",
        resolver: plan.FunctionResolver(
          document.Resolver(resolver: fn(_inputs) {
            engine.finish_plan(
              engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
              fn(_memory) { Ok(dynamic.nil()) },
            )
          }),
        ),
      ),
      [],
      engine,
      kv.new(),
      interpret_plan.interpret,
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

pub fn interpret_step_runs_inline_resolver_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(9))
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "inline",
        resolver: plan.InlineResolver(
          plan: plan.Plan(
            routes: [plan.Route(from: ["value"], to: ["output"])],
            batches: [],
          ),
        ),
      ),
      [plan.Route(from: ["input"], to: ["inline", "value"])],
      engine,
      memory,
      fn(_plan, memory, engine, parameters) {
        engine.start_plan(fn() {
          let assert Ok(memory) = progress.add_parameters(memory, parameters)
          Ok(#(memory, []))
        })
      },
    )

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        let assert Ok(output) = kv.get(memory, ["inline", "output"])
        assert decode.run(output, decode.int) == Ok(9)
        Ok(dynamic.nil())
      }),
    )
  })
}
