import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/engine/basic
import webql/memory/kv
import webql/runner/run_batch
import webql/runner/run_plan
import webql/schema

pub fn run_batch_runs_step_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(4))
  let task =
    run_batch.run(
      [
        plan.Step(
          name: "inc",
          node: plan.Node(
            schema.Resolver(resolver: fn(inputs) {
              let assert Ok(inputs) =
                decode.run(inputs, decode.dict(decode.string, decode.dynamic))
              let assert Ok(raw_number) = dict.get(inputs, "n")
              let assert Ok(number) = decode.run(raw_number, decode.int)

              engine.handle_finish_plan(
                engine.handle_start_plan(fn() { Ok(#(kv.new(), [])) }),
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
      ],
      [
        plan.Edge(
          source: plan.Output(path: ["input"]),
          target: plan.Input(path: ["inc", "n"]),
        ),
      ],
      engine,
      memory,
      run_plan.run,
    )

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        let assert Ok(output) = kv.get(memory, ["inc", "value"])
        assert decode.run(output, decode.int) == Ok(5)
        Ok(dynamic.nil())
      }),
    )
  })
}

pub fn run_batch_runs_empty_batch_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(42))
  let task = run_batch.run([], [], engine, memory, run_plan.run)

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        let assert Ok(value) = kv.get(memory, ["input"])
        assert decode.run(value, decode.int) == Ok(42)
        Ok(dynamic.nil())
      }),
    )
  })
}

pub fn run_batch_runs_multiple_steps_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["n"], dynamic.int(3))
  let task =
    run_batch.run(
      [
        plan.Step(
          name: "double",
          node: plan.Node(
            schema.Resolver(resolver: fn(inputs) {
              let assert Ok(inputs) =
                decode.run(inputs, decode.dict(decode.string, decode.dynamic))
              let assert Ok(raw_value) = dict.get(inputs, "x")
              let assert Ok(value) = decode.run(raw_value, decode.int)

              engine.handle_finish_plan(
                engine.handle_start_plan(fn() { Ok(#(kv.new(), [])) }),
                fn(_memory) {
                  Ok(
                    dynamic.properties([
                      #(dynamic.string("result"), dynamic.int(value * 2)),
                    ]),
                  )
                },
              )
            }),
          ),
        ),
        plan.Step(
          name: "inc",
          node: plan.Node(
            schema.Resolver(resolver: fn(inputs) {
              let assert Ok(inputs) =
                decode.run(inputs, decode.dict(decode.string, decode.dynamic))
              let assert Ok(raw_value) = dict.get(inputs, "x")
              let assert Ok(value) = decode.run(raw_value, decode.int)

              engine.handle_finish_plan(
                engine.handle_start_plan(fn() { Ok(#(kv.new(), [])) }),
                fn(_memory) {
                  Ok(
                    dynamic.properties([
                      #(dynamic.string("result"), dynamic.int(value + 1)),
                    ]),
                  )
                },
              )
            }),
          ),
        ),
      ],
      [
        plan.Edge(
          source: plan.Output(path: ["n"]),
          target: plan.Input(path: ["double", "x"]),
        ),
        plan.Edge(
          source: plan.Output(path: ["n"]),
          target: plan.Input(path: ["inc", "x"]),
        ),
      ],
      engine,
      memory,
      run_plan.run,
    )

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        let assert Ok(doubled) = kv.get(memory, ["double", "result"])
        let assert Ok(incremented) = kv.get(memory, ["inc", "result"])
        assert decode.run(doubled, decode.int) == Ok(6)
        assert decode.run(incremented, decode.int) == Ok(4)
        Ok(dynamic.nil())
      }),
    )
  })
}
