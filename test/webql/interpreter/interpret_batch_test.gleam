import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/document
import webql/engine/transient
import webql/interpreter/interpret_batch
import webql/interpreter/interpret_plan
import webql/memory/kv

pub fn interpret_batch_runs_step_test() {
  let engine = transient.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(4))
  let task =
    interpret_batch.interpret(
      [
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
      ],
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

pub fn interpret_batch_runs_empty_batch_test() {
  let engine = transient.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(42))
  let task =
    interpret_batch.interpret([], [], engine, memory, interpret_plan.interpret)

  engine.finish_plan(task, fn(memory) {
    let assert Ok(value) = kv.get(memory, ["input"])
    assert decode.run(value, decode.int) == Ok(42)
    Ok(dynamic.nil())
  })
}

pub fn interpret_batch_runs_multiple_steps_test() {
  let engine = transient.new()
  let memory = kv.set(kv.new(), ["n"], dynamic.int(3))
  let task =
    interpret_batch.interpret(
      [
        plan.Step(
          name: "double",
          resolver: plan.FunctionResolver(
            document.Resolver(resolver: fn(inputs) {
              let assert Ok(inputs) =
                decode.run(inputs, decode.dict(decode.string, decode.dynamic))
              let assert Ok(x) = dict.get(inputs, "x")
              let assert Ok(x) = decode.run(x, decode.int)

              engine.finish_plan(
                engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
                fn(_memory) {
                  Ok(
                    [#(dynamic.string("result"), dynamic.int(x * 2))]
                    |> dynamic.properties(),
                  )
                },
              )
            }),
          ),
        ),
        plan.Step(
          name: "inc",
          resolver: plan.FunctionResolver(
            document.Resolver(resolver: fn(inputs) {
              let assert Ok(inputs) =
                decode.run(inputs, decode.dict(decode.string, decode.dynamic))
              let assert Ok(x) = dict.get(inputs, "x")
              let assert Ok(x) = decode.run(x, decode.int)

              engine.finish_plan(
                engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
                fn(_memory) {
                  Ok(
                    [#(dynamic.string("result"), dynamic.int(x + 1))]
                    |> dynamic.properties(),
                  )
                },
              )
            }),
          ),
        ),
      ],
      [
        plan.Route(from: ["n"], to: ["double", "x"]),
        plan.Route(from: ["n"], to: ["inc", "x"]),
      ],
      engine,
      memory,
      interpret_plan.interpret,
    )

  engine.finish_plan(task, fn(memory) {
    let assert Ok(doubled) = kv.get(memory, ["double", "result"])
    let assert Ok(incremented) = kv.get(memory, ["inc", "result"])
    assert decode.run(doubled, decode.int) == Ok(6)
    assert decode.run(incremented, decode.int) == Ok(4)
    Ok(dynamic.nil())
  })
}
