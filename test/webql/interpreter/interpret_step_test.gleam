import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/document
import webql/engine/transient
import webql/interpreter/interpret_plan
import webql/interpreter/interpret_step
import webql/interpreter/progress
import webql/memory/kv

pub fn interpret_step_runs_function_resolver_test() {
  let engine = transient.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(4))
  let task =
    interpret_step.interpret(
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
      [plan.Route(from: ["input"], to: ["inc", "n"])],
      engine,
      memory,
      interpret_plan.interpret,
    )

  engine.finish_plan(task, fn(memory) {
    let assert Ok(output) = kv.get(memory, ["inc", "value"])
    assert decode.run(output, decode.int) == Ok(5)
    Ok(dynamic.nil())
  })
}

pub fn interpret_step_reports_missing_input_test() {
  let engine = transient.new()
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

  engine.finish_step(task, fn(result) {
    let assert Error(_) = result
    Ok(kv.new())
  })
}

pub fn interpret_step_reports_invalid_output_test() {
  let engine = transient.new()
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

  engine.finish_step(task, fn(result) {
    let assert Error(_) = result
    Ok(kv.new())
  })
}

pub fn interpret_step_runs_inline_resolver_test() {
  let engine = transient.new()
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

  engine.finish_plan(task, fn(memory) {
    let assert Ok(output) = kv.get(memory, ["inline", "output"])
    assert decode.run(output, decode.int) == Ok(9)
    Ok(dynamic.nil())
  })
}
